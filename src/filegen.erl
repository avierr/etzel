-module(filegen).
-compile(export_all).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% Public API

start() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

stop(Module) ->
  gen_server:call(Module, stop).

stop() ->
  stop(?MODULE).

state(Module) ->
  gen_server:call(Module, state).

state() ->
  state(?MODULE).

%% Server implementation, a.k.a.: callbacks

init([]) ->
  say("\n Disk Persistance Server Initiated \n", []),
  {ok, Ref} = eleveldb:open("ldt", [{create_if_missing, true}]),
  {ok, {Ref}}.

load_from_disk(I,Counter) ->
    
    case Counter==0 of

      true -> 
                  X=eleveldb:iterator_move(I, <<>>),
                    io:format("\n ~w \n",[X]);
      false ->
                  X=eleveldb:iterator_move(I, next),
                    io:format("\n ~w \n",[X])
    end,


                  

    case Counter>100 of
        true ->
           1=1;
        false ->
            
            load_from_disk(I,Counter+1)
     end.          

handle_call(lfd, _From, {Ref}) ->

    {ok, I} = eleveldb:iterator(Ref, []),
    load_from_disk(I,0),
  {reply, ok, {Ref}};


handle_call({push, Queue,Item,Tail}, _From, {Ref}) ->
  QKey = erlang:iolist_to_binary([Queue,integer_to_binary(Tail)]),
  QTail = erlang:iolist_to_binary([Queue,<<"T">>]),
  io:format("\n ~w ~w ~w \n",[QKey, QTail, Item]),
  eleveldb:put(Ref, QTail, integer_to_binary(Tail), []),
  eleveldb:put(Ref, QKey,  erlang:iolist_to_binary([Item]), []),


  case Tail  of
    0 ->
        QHead = erlang:iolist_to_binary([Queue,<<"H">>]),
        eleveldb:put(Ref, QHead, integer_to_binary(0), []);
    _ -> 1=1
  end,

  {reply, ok, {Ref}};

handle_call({pop, Queue, Head}, _From, {Ref}) ->

  %delete record
  THead=Head-1,
  QKey = erlang:iolist_to_binary([Queue,<<"*">>,integer_to_binary(THead)]),
  eleveldb:delete(Ref, QKey,[]),

  %increment Head 
  QHead = erlang:iolist_to_binary([Queue,<<"H">>]),
  eleveldb:put(Ref, QHead, integer_to_binary(Head), []),

  {reply, ok, {Ref}};


handle_call(stop, _From, State) ->
  say("stopping by ~p, state was ~p.", [_From, State]),
  {stop, normal, stopped, State};

handle_call(state, _From, State) ->
  say("~p is asking for the state.", [_From]),
  {reply, State, State};

handle_call(_Request, _From, State) ->
  say("call ~p, ~p, ~p.", [_Request, _From, State]),
  {reply, ok, State}.


handle_cast(_Msg, State) ->
  say("cast ~p, ~p.", [_Msg, State]),
  {noreply, State}.


handle_info(_Info, State) ->
  say("info ~p, ~p.", [_Info, State]),
  {noreply, State}.


terminate(_Reason, _State) ->
  say("terminate ~p, ~p", [_Reason, _State]),
  ok.


code_change(_OldVsn, State, _Extra) ->
  say("code_change ~p, ~p, ~p", [_OldVsn, State, _Extra]),
  {ok, State}.

%% Some helper methods.

say(Format) ->
  say(Format, []).
say(Format, Data) ->
  io:format("~p:~p: ~s~n", [?MODULE, self(), io_lib:format(Format, Data)]).


