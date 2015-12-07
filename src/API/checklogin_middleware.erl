-module(checklogin_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->

	  {BlnLoggedIn,Req2}=cowboy_session:get("loggedin",  Req),


	  {Path, _} = cowboy_req:path(Req2),

	  io:format("~p",[Path]),

	case BlnLoggedIn of

		true ->
				{ok, Req2, Env};
		_ ->
				
				Resp= 	jiffy:encode({[{<<"result">>, <<"error">>},{<<"errCode">>,<<"NOAUTH">>},{<<"msg">>,<<"you are not logged in or have enough privilages">>}]}),

				{ok, Req3} = cowboy_req:reply(200,
				[{<<"content-type">>, <<"text/html">>}],
			       	Resp,
			         Req2),

				{ok, Req3, Env}		

	end.