-module(checklogin_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->

	  {BlnLoggedIn,Req2}=cowboy_session:get("loggedin",  Req),


	  {Path, Req3} = cowboy_req:path(Req2),

	  io:format("~p",[Path]),


	  %To remove the trailing slash
	  %first append //
	  Path2 = iolist_to_binary([Path,<<"//">>]),
	  %replace /// with null 
	  Path3 = binary:replace(Path2,<<"///">>,<<"">>), %if trailing slash existed
	  Path4 = binary:replace(Path3,<<"//">>,<<"">>),  %if there was no trailing slash


	  Restricted_paths = [<<"/user/get_session">>],





	case BlnLoggedIn  of

		true ->
				{ok, Req3, Env};
		_ ->

				case lists:member(Path4,Restricted_paths) of 

					true -> 
				
								  io:format("~pHere",[Path]),

							Resp= 	jiffy:encode({[{<<"result">>, <<"error">>},{<<"errCode">>,<<"NOAUTH">>},{<<"msg">>,<<"you are not logged in or have enough privilages">>}]}),

							{ok, Req4} = cowboy_req:reply(200,
													[{<<"content-type">>, <<"text/html">>}],
			       									Resp,
			         								Req3),

							{ok, Req4, Env};

					_->

						  io:format("~pThere",[Path]),

							{ok,Req,Env}	

				end				

	end.