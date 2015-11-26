-module(servermanager).

-behaviour(gen_server).

-export([start_link/0]).

%list_projects(uid)
%list_queues(pid)
%get_queue_stat(pid,qname)
%delete_queue(qname)
%create_queue(qname)


%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3,
         get_random_string/2]).



start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
   
   Prefix=0,

    {ok, {Prefix}}.

handle_call(getuid,_From,{Prefix}) ->

    Reply = 1,

    {reply,Reply,{Prefix}};

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


get_random_string(Length, AllowedChars) ->
    lists:foldl(fun(_, Acc) ->
                        [lists:nth(random:uniform(length(AllowedChars)),
                                   AllowedChars)]
                            ++ Acc
                end, [], lists:seq(1, Length)).
%% Internal functions
