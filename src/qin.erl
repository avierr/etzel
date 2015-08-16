

-module(qin).
-export([starten/0,
            select_task/1,
            exec_task/2,
            real_publish/2,
            push_to_disk/6]).
%-on_load(starten/0).

starten() ->
    io:format(" starting...\n").

select_task(Data) ->
    Map=jiffy:decode(Data,[return_maps]),
    Cmd=maps:get(<<"cmd">>,Map),
    exec_task(Cmd,Map).
    
exec_task(<<"SUB">>,Map) ->
    Qname=maps:get(<<"qname">>,Map),
    pg2:create(Qname),
    pg2:join(Qname,self()),
    R = jiffy:encode({[{<<"cmd">>, <<"oksub">>},{<<"qname">>,Qname}]}),    
    R = R;



exec_task(<<"ACK">>,Map) ->
    Uid=maps:get(<<"uid">>,Map),
    Qname=maps:get(<<"qname">>,Map),
    ets:insert(etzel_delset, {Uid, ok}),
    gen_server:call(whereis(filegen),{del,Qname,Uid}),
    R = jiffy:encode({[{<<"cmd">>, <<"okack">>},{<<"uid">>,Uid},{<<"qname">>,Qname}]}),    
    R=R;

exec_task(<<"ISLP">>,Map) ->
    Qname=maps:get(<<"qname">>,Map),
    SQname = erlang:iolist_to_binary([Qname,<<"_S">>]),
    pg2:create(SQname),
    pg2:join(SQname,self()),
    R = jiffy:encode({[{<<"cmd">>, <<"okslp">>},{<<"qname">>,Qname}]}),
    R = R;

    %io:format("\nSUB TO: ~s",[Qname]);   

exec_task(<<"FET">>,Map) ->
        %Ret = <<"{'cmd':'ok'}">>,
        %io:format("FET cmd recvd."),
        Qname=maps:get(<<"qname">>,Map),

        PQname = erlang:iolist_to_binary([Qname,<<"_P">>]), % join 2 bin. string
        pg2:create(PQname),
        case pg2:get_members(PQname) of
            
            [] -> 
                <<"{\"cmd\":\"nok\",\"err\":\"Q_NOT_FOUND\"}">>;

            Otherwise ->   
                [Px|_]=Otherwise,
                Ret=gen_server:call(Px,{pop}),
                 case Ret of 
                    no_item -> 
                        %self() ! jiffy:encode({[{<<"cmd">>, <<"okslp">>},{<<"qname">>,Qname}]}),
                        Z={[{<<"cmd">>, <<"nomsg">>},{<<"qname">>,Qname}]},
                        jiffy:encode(Z);
                    _ ->  


                        %lets break the message: err_count(8)| expires(64b)|uidlen(16)|uid(Variable)|msg(Variable)
                        <<ErrorCount:8>> =  binary:part(Ret,0,1), %get error_count
                        <<Expires:64>> = binary:part(Ret,1,8),
                        <<Uidlen:16>> = binary:part(Ret,9,2), %get uidlen
                        Uid = binary:part(Ret,11,Uidlen), %get the uid

                        {Mega, Secs, _} = os:timestamp(),
                        Timestamp = Mega*1000000 + Secs,

                        case Timestamp > Expires of 

                            false ->

                                    case ets:lookup(etzel_delset,Uid) of

                                        [] ->

                                            MsgLen = byte_size(Ret)-(Uidlen+11),
                                            Msg = binary:part(Ret,Uidlen+11, MsgLen), %get the msg
                                            
                                            % get uidlen+uid+msg: 2bytes for uidlen+actual uidlen +msglen
                                            UidMsgBin = binary:part(Ret,9,2+Uidlen+MsgLen), 

                                            NewErrorCount=ErrorCount+1,
                                            MemItem=iolist_to_binary([<<NewErrorCount:8>>,<<Expires:64>>,UidMsgBin]),
                                            %increment error count on disk
                                            push_to_disk(Qname,Uid,NewErrorCount,0,Expires,Msg),
                                            timer:apply_after(60*1000,qin,real_publish,[Qname,MemItem]),
                                            Z = {[{<<"cmd">>, <<"msg">>},{<<"qname">>,Qname},{<<"uid">>,Uid},{<<"msg">>,Msg}]},
                                            R = jiffy:encode(Z),
                                            R = R;
                                        [{_,_}] ->
                                                ets:delete(etzel_delset, Uid),
                                                exec_task(<<"FET">>,Map)
                                    end;
                            true ->
                                    %io:format("\ndeleted",[]),
                                    gen_server:call(whereis(filegen),{del,Qname,Uid}),
                                    exec_task(<<"FET">>,Map)
                            
                        end                    
                end        

        end;


exec_task(<<"PUB">>,Map) ->

    Ts=maps:get(<<"delay">>,Map),

    exec_publish(Ts,Map);
    

exec_task(_,_) ->
    io:format("Invalid Task.").    


exec_publish(0,Map)->
        Qname=maps:get(<<"qname">>,Map),
        Msg=maps:get(<<"msg">>,Map),
        Delay=maps:get(<<"delay">>,Map),
        Expires=maps:get(<<"expires">>,Map),
        {MemItem,Uid}=gen_msg(Msg,Expires),
        push_to_disk(Qname,Uid,0,Delay,Expires,Msg),
        real_publish(Qname,MemItem);
  


exec_publish(Ts,Map)->
        Qname=maps:get(<<"qname">>,Map),
        Msg=maps:get(<<"msg">>,Map),
        Delay=maps:get(<<"delay">>,Map),
        Expires=maps:get(<<"expires">>,Map),
        {MemItem,Uid}=gen_msg(Msg,Expires),
        push_to_disk(Qname,Uid,0,Delay,Expires,Msg),
        timer:apply_after(Ts*1000,qin,real_publish,[Qname,MemItem]),
        Ret = <<"{\"cmd\":\"ok\"}">>,
        Ret=Ret.


real_publish(Qname,Msg) ->
    %get list of members from intersection(Q,sleepQ) 
    %and send a AWAKE message 
    pg2:create(Qname),

    %create sleep Q. name for THE queue
    SQname = erlang:iolist_to_binary([Qname,<<"_S">>]),
    pg2:create(SQname),
    L1 = pg2:get_members(Qname),
    L2 = pg2:get_members(SQname),
    S1 = sets:from_list(L1),
    S2 = sets:from_list(L2),
    S3 = sets:intersection(S1,S2),
    ListOfPids = sets:to_list(S3),
    OMessage = {[{<<"cmd">>, <<"awk">>},{<<"qname">>,Qname}]},
    Message = jiffy:encode(OMessage),
    [Pid ! Message || Pid <- ListOfPids],
    [pg2:leave(SQname,X) || X <- ListOfPids], 
    
    %make pname that holds the queue
    PQname = erlang:iolist_to_binary([Qname,<<"_P">>]), % join 2 bin. string
    pg2:create(PQname),
    case pg2:get_members(PQname) of
        
        [] -> 
           % io:format("hi"),

           case ets:lookup(etzel_delset,qreglock) of
            [{_,0}] ->
                    ets:insert(etzel_delset, {qreglock, 1}),
                    {ok,P2}=tq:start_link(),
                    pg2:join(PQname,P2),
                    ets:insert(etzel_delset, {qreglock, 0}),
                    gen_server:call(P2,{push,Msg}),
                    <<"{\"cmd\":\"ok\"}">>;
            [{_,1}] ->
                    %try again
                    qin:real_publish(Qname,Msg)
            end;

        Otherwise ->   
            %io:format("bye"),
            [Px|_]=Otherwise,
            gen_server:call(Px,{push,Msg}),
            <<"{\"cmd\":\"ok\"}">>
      end.


            


%Disk: Q-uid: errc|delay|expires|item
%Mem : errc|expires|UidLen|Q-uid|Item

gen_msg(Msg,Expires)->
        Uid=gen_server:call(whereis(uidgen),getuid),
        Uid_size=byte_size(Uid),

        {Mega, Secs, _} = os:timestamp(),
        Timestamp = Mega*1000000 + Secs,
        TExpires = Timestamp + Expires,
        MemItem = iolist_to_binary([<<0:8>>,<<TExpires:64>>,<<Uid_size:16>>,Uid,Msg]),
        {MemItem,Uid}.


push_to_disk(Qname,Uid,ErrorCount,Delay,Expires,Item)->

    gen_server:call(whereis(filegen),{push,Qname,Uid,ErrorCount,Delay,Expires,Item}).



