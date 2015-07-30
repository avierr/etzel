

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
    pg2:join(Qname,self()),
    io:format("\nSUB TO: ~s",[Qname]);   

% exec_task(<<"FET">>,Map) ->
%     Qname=maps:get(<<"qname">>,Map),
%     pg2:create(Qname),
%     pg2:join(Qname,self()),
%     io:format("\nSUB TO: ~s",[Qname]);   

exec_task(<<"PUB">>,Map) ->
    %get list of members from intersection(Q,sleepQ) 
    %and send a AWAKE message 
    Qname=maps:get(<<"qname">>,Map),
    L1 = pg2:get_members(Qname),
    L2 = pg2:get_members(<<"__SLPL">>),
    S1 = sets:from_list(L1),
    S2 = sets:from_list(L2),
    S3 = sets:intersection(S1,S2),
    ListOfPids = sets:to_list(S3),
    Message = <<"{'cmd':'AWK'}">>,
    [Pid ! Message || Pid <- ListOfPids],
    io:format("PUB cmd recvd.");

exec_task(_,_) ->
    io:format("Invalid Task.").    

