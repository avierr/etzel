-module(etzel_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    spawn(qin,starten,[]),
    pg2:create(<<"__SLPL">>), %create a sleep list for proceses
    Dispatch = cowboy_router:compile([
        {'_', [{"/", hello_handler, []},
                {"/connect/",ws_handler, []}
               ]}
        
    ]),
    {ok, _} = cowboy:start_http(my_http_listener, 100, [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),


    {ok,_} = filegen:start(),
    {ok,_} = uidgen:start_link(),
    %register(pdb, Ref), % Init primary DB

	etzel_sup:start_link().

stop(_State) ->
	ok.
