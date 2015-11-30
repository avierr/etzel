-module(login_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {
}).

init(_, Req, _Opts) ->
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->



	Resp = case cowboy_req:has_body(Req) of


		true ->

				{ok, BodyQs, _Req} = cowboy_req:body_qs(Req),
  				Username = proplists:get_value(<<"username">>, BodyQs),
  				Password = proplists:get_value(<<"password">>, BodyQs),
  				{Result,IdOrError,UsernameOrMsg}=gen_server:call(whereis(servermanager),{login_user,Username,Password}),

  				case Result of

  					error ->

  							jiffy:encode({[{<<"result">>, <<"error">>},{<<"errCode">>,IdOrError},{<<"msg">>,UsernameOrMsg}]});

  					ok ->

  							jiffy:encode({[{<<"result">>, <<"ok">>},{<<"id">>,IdOrError},{<<"username">>,UsernameOrMsg}]})

  				end;	



		false ->

				   jiffy:encode({[{<<"result">>, <<"error">>},{<<"msg">>,<<"No POST parameters, requires username and password.">>}]})  

	end,
	

	{ok, Req2} = cowboy_req:reply(200,
					[{<<"content-type">>, <<"text/html">>}],
       				 Resp,
         		Req),

	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
