-module(get_session).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, _Opts) ->
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->

  {BlnLoggedIn,Req2}=cowboy_session:get("loggedin",  Req),
  {IntUid,Req3}=cowboy_session:get("uid", Req2),
  {StrUsername,Req4}=cowboy_session:get("username", Req3),

  Resp = jiffy:encode({[{<<"loggedin">>, BlnLoggedIn},{<<"id">>,IntUid},{<<"username">>,StrUsername}]}),


	{ok, ReqFinal} = cowboy_req:reply(200,
					[{<<"content-type">>, <<"text/html">>}],
       				 Resp,
         		Req4),

	{ok, ReqFinal, State}.

terminate(_Reason, _Req, _State) ->
	ok.
