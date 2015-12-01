-module(hello_handler).
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
    {ok, Data} = file:read_file("ext/tpl/login.html"),
    {ok, Home} = file:read_file("ext/tpl/etzelhome.html"),

    Con = dict:from_list([{content, binary_to_list(Data)},{menu, binary_to_list(Menu)}]),
    Result=mustache:render(binary_to_list(Home), Con),

    {ok, Req2} = cowboy_req:reply(200,
	[{<<"content-type">>, <<"text/html">>}],
        Result,
         Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
