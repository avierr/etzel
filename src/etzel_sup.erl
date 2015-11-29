-module(etzel_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

  	DataManager = {datamanager, {datamanager, start_link, []},
           permanent, 2000, worker, [datamanager]},
	
  	ServerManager = {servermanager, {servermanager, start_link, []},
           permanent, 2000, worker, [servermanager]},

	Procs = [DataManager, ServerManager],
	{ok, {{one_for_one, 1, 5}, Procs}}.
