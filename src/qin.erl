

-module(qin).
-export([starten/0,select_task/1,exec_task/1]).
%-on_load(starten/0).

starten() ->
    io:format("\nstajtnes\n").

select_task(Data) ->
    Map=jiffy:decode(Data,[return_maps]),
    Cmd=maps:get(<<"cmd">>,Map),
    exec_task(Cmd).
    
exec_task(<<"SUB">>) ->
    io:format("SUB cmd recvd.");   



exec_task(_) ->
    io:format("Invalid Task.").    

