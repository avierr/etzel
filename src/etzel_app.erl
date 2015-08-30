-module(etzel_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    spawn(qin,starten,[]),
    pg2:create(<<"__SLPL">>), %create a sleep list for proceses
    Dispatch = cowboy_router:compile([
        {'_', [{"/", hello_handler, []},
        		{"/login/", login_handler, []},
                {"/connect/",ws_handler, []}
               ]}
        
    ]),
    {ok, _} = cowboy:start_http(my_http_listener, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),


    {ok, Data} = file:read_file("ext/opener.txt"),
    io:format("~s",[Data]),
    ets:new(etzel_delset, [public,set, named_table]),
    ets:insert(etzel_delset, {qreglock, 0}),
    {ok,_} = uidgen:start_link(),
    {ok,FP} = filegen:start(),
    gen_server:call(FP,lfd),


	etzel_sup:start_link().

stop(_State) ->
	ok.
