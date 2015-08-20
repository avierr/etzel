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
  say("\nFilegen: Persistance Server Initiated. \n", []),
  {ok, Ref} = eleveldb:open("ldt", [{create_if_missing, true}]),
  {ok, {Ref}}.

load_from_disk(I,Counter,Ref) ->
    
    Fl = case Counter==0 of

      true -> 
                  <<>>;
      false ->
                   next
    end,

   Res = case eleveldb:iterator_move(I, Fl) of
      
      {error,invalid_iterator} -> error;
    
      {A,Key,Val} ->
        %io:format("\n ~w ~w ~w \n",[A,Key,Val]),
        QnId=binary:split(Key,<<"*">>,[]),
        [Qname,Uid]=QnId,
        %[|_]=QnId,

        io:format("\n ~w \n",[QnId]),

        %E|DDDDDDDD|XXXXXXXX|Item(variable len)  
        <<ErrorCount:8>> = binary:part(Val,0,1),
        <<Delay:64>> = binary:part(Val,1,8),
        <<Expires:64>> = binary:part(Val,9,8),

        %get current UNIX TimeStamp
        {Mega, Secs, _} = os:timestamp(),
        Timestamp = Mega*1000000 + Secs,

        %Calculate the new Delay
        NDelay = case Timestamp > Delay of
                    
                    true -> 0;

                    false -> Delay - Timestamp

                  end,  

        %insert to memory only if not expired

        case Timestamp < Expires of

            true ->
              Uid_size = byte_size(Uid),
              Msg = binary:part(Val,17,byte_size(Val)-(1+8+8)), %size(errc)+size(delay)+size(expires)
              MemItem = iolist_to_binary([<<ErrorCount:8>>,<<Expires:64>>,<<Uid_size:16>>,Uid,Msg]),
              %io:format("\nN: ~p \n",[Qname]),

              case NDelay of 

                0 -> 
                    qin:real_publish(Qname,MemItem);
                _ ->
               
                  timer:apply_after(NDelay*1000,qin,real_publish,[Qname,MemItem])
                end;  
            false -> 
                   % io:format("\nDel.call\n"),
                    eleveldb:delete(Ref, Key,[])
         end,            

        A=A
    end,    

                  

    case Res /= ok of
        true ->
           1=1;
        false ->
            load_from_disk(I,Counter+1,Ref)
     end.          

handle_call(lfd, _From, {Ref}) ->

    {ok, I} = eleveldb:iterator(Ref, []),
    load_from_disk(I,0,Ref),
  {reply, ok, {Ref}};




handle_call(retref, _From, {Ref}) ->
  {reply, Ref, {Ref}};

handle_call({push, Queue,Uid,ErrorCount,Delay,Expires,Item}, _From, {Ref}) ->

  QKey = erlang:iolist_to_binary([Queue,<<"*">>,Uid]),

  {Mega, Secs, _} = os:timestamp(),
  Timestamp = Mega*1000000 + Secs,
  TDelay = Timestamp + Delay,


  TExpires = case Expires of
              0 -> 
                  Timestamp + 31536000;
              _ ->
                  Timestamp + Expires
              end,    

  QItem = erlang:iolist_to_binary([<<ErrorCount:8>>,
                                   <<TDelay:64>>,
                                   <<TExpires:64>>,
                                   Item]),

  %io:format("\n ~w ~w  \n",[QKey, QItem]),
  eleveldb:put(Ref, QKey, QItem, []),

  {reply, ok, {Ref}};

handle_call({del, Queue,Uid}, _From, {Ref}) ->

  QKey = erlang:iolist_to_binary([Queue,<<"*">>,Uid]),
  eleveldb:delete(Ref, QKey,[]),

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


