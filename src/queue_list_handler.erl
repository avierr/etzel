-module(queue_list_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, _Opts) ->
    {ok, Req, #state{}}.

handle(Req, State=#state{}) ->

    {ok, Menu} = file:read_file("ext/tpl/menu.html"),
    {ok, Home} = file:read_file("ext/tpl/etzelhome.html"),
    {ok, Queues} = file:read_file("ext/tpl/queues.html"),
    Ctx = dict:from_list([{menu, binary_to_list(Menu)},{queues,binary_to_list(Queues)}]),
    Result=mustache:render(binary_to_list(Home), Ctx),

    {ok, Req2} = cowboy_req:reply(200,
    [{<<"content-type">>, <<"text/html">>}],
        Result,
         Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.
