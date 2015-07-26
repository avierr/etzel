

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

exec_task(<<"PUB">>,Map) ->
    Map=Map,
    io:format("PUB cmd recvd.");

exec_task(_,_) ->
    io:format("Invalid Task.").    

