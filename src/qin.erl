

-module(qin).
-export([starten/0,select_task/1,exec_task/2]).
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
    pg2:join(Qname,self());
    %io:format("\nSUB TO: ~s",[Qname]);   

% exec_task(<<"FET">>,Map) ->
%     Qname=maps:get(<<"qname">>,Map),
%     pg2:create(Qname),
%     pg2:join(Qname,self()),
%     io:format("\nSUB TO: ~s",[Qname]);   

exec_task(<<"FET">>,Map) ->
        %Ret = <<"{'cmd':'ok'}">>,
        %io:format("FET cmd recvd."),
        Qname=maps:get(<<"qname">>,Map),

    PQname = erlang:iolist_to_binary([Qname,<<"_P">>]), % join 2 bin. string
    pg2:create(PQname),
    case pg2:get_members(PQname) of
        
        [] -> 
            <<"{\"cmd\":\"nok\",\"err\":\"Q not found\"}">>;

        Otherwise ->   
            [Px|_]=Otherwise,
            Ret=gen_server:call(Px,pop),
            Y = case Ret of 
                no_item -> 
                    {[{<<"cmd">>, <<"nomsg">>}]};

                    _ ->   

                    {[{<<"cmd">>, <<"msg">>},{<<"qname">>,Qname},{<<"msg">>,Ret}]}
            end,        
            R = jiffy:encode(Y),
            R = R
      end;


exec_task(<<"PUB">>,Map) ->
    %get list of members from intersection(Q,sleepQ) 
    %and send a AWAKE message 
    Qname=maps:get(<<"qname">>,Map),
    Msg=maps:get(<<"msg">>,Map),
    pg2:create(Qname),
    L1 = pg2:get_members(Qname),
    L2 = pg2:get_members(<<"__SLPL">>),
    S1 = sets:from_list(L1),
    S2 = sets:from_list(L2),
    S3 = sets:intersection(S1,S2),
    ListOfPids = sets:to_list(S3),
    Message = <<"{\"cmd\":\"AWK\"}">>,
    [Pid ! Message || Pid <- ListOfPids],
    
    %make pname that holds the queue
    PQname = erlang:iolist_to_binary([Qname,<<"_P">>]), % join 2 bin. string
    pg2:create(PQname),
    case pg2:get_members(PQname) of
        
        [] -> 
           % io:format("hi"),
            {ok,P2}=tq:start_link(),
            pg2:join(PQname,P2),
            gen_server:call(P2,{push,Msg});

        Otherwise ->   
            %io:format("bye"),
            [Px|_]=Otherwise,
            gen_server:call(Px,{push,Msg})
      end,      

    Ret = <<"{\"cmd\":\"ok\"}">>,
    Ret=Ret;

exec_task(_,_) ->
    io:format("Invalid Task.").    


