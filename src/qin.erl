

-module(qin).
-export([starten/0,select_task/1,exec_task/2,real_publish/1]).
%-on_load(starten/0).

starten() ->
    io:format("\nstajtnes\n").

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
                Ret=gen_server:call(Px,{pop,Qname}),
                Y = case Ret of 
                    no_item -> 
                        %self() ! jiffy:encode({[{<<"cmd">>, <<"okslp">>},{<<"qname">>,Qname}]}),
                        {[{<<"cmd">>, <<"nomsg">>},{<<"qname">>,Qname}]};

                        _ ->   

                        {[{<<"cmd">>, <<"msg">>},{<<"qname">>,Qname},{<<"msg">>,Ret}]}
                end,        
                R = jiffy:encode(Y),
                R = R
          end;


exec_task(<<"PUB">>,Map) ->

    Ts=maps:get(<<"delay">>,Map),

    exec_publish(Ts,Map);
    

exec_task(_,_) ->
    io:format("Invalid Task.").    


exec_publish(0,Map)->
            real_publish(Map);
  


exec_publish(Ts,Map)->
        timer:apply_after(Ts*1000,qin,real_publish,[Map]),
        Ret = <<"{\"cmd\":\"ok\"}">>,
        Ret=Ret.


real_publish(Map) ->
%get list of members from intersection(Q,sleepQ) 
    %and send a AWAKE message 
    Qname=maps:get(<<"qname">>,Map),
    Msg=maps:get(<<"msg">>,Map),
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
            {ok,P2}=tq:start_link(),
            pg2:join(PQname,P2),
            gen_server:call(P2,{push,Msg,Qname});

        Otherwise ->   
            %io:format("bye"),
            [Px|_]=Otherwise,
            gen_server:call(Px,{push,Msg,Qname})
      end,      

    Ret = <<"{\"cmd\":\"ok\"}">>,
    Ret=Ret.



