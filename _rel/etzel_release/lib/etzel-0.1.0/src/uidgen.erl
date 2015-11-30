-module(uidgen).

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).



start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    random:seed(os:timestamp()),

    Str = commonlib:get_random_string(2,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"),
    Strbin = erlang:list_to_binary(Str),
    {Mega, Secs, _} = os:timestamp(),

    Timestamp = Mega*1000000 + Secs,
    Timestampbin = erlang:integer_to_binary(Timestamp),

    Prefix = iolist_to_binary([Strbin,Timestampbin,<<"_">>]),
    io:format("\nUidgen server started with prefix: ~w \n",[Prefix]),

    {ok, {Prefix,250}}.

handle_call(getuid,_From,{Prefix,Counter}) ->

    Reply = iolist_to_binary([Prefix,integer_to_binary(Counter)]),

    {reply,Reply,{Prefix,Counter+1}};

   

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


