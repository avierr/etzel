-module(tq).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, 
	handle_info/2, terminate/2, code_change/3,
	start_link/0]).

init([])->
      {ok, {queue:new(), 0}}.

start_link() -> gen_server:start_link(?MODULE, [], []).
 
handle_call({push, Item}, _From, {MyQueue, Len}) ->
    io:format("\n  ~w \n",[Item]),
    {reply, ok, {queue:in(Item, MyQueue), Len + 1}};
 
handle_call({pop}, _From, {MyQueue, Len})->
    case queue:out(MyQueue) of
        {{value, Item}, Q} ->
           {reply, Item, {Q, Len -1}};

        {empty, Q} ->
           {reply, no_item, {Q, Len}}
     end.      

handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
