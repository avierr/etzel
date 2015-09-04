-module(etzeldisk).
-compile(export_all).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% Public API

start_link() ->
 gen_server:start_link(?MODULE, [], []).

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

	{ok, FRef} = file:open(<<"0">>, [read, append, raw, binary]),

	
	%H(offset), T(offset), Tcount, CurrOpenFile, CurrFileRef, MetaFile, MetaFileRef
  {ok, {0,0,0,0,<<"0">>,FRef,<<"0">>,FRef}}.





handle_call({push,Pname,Qname,ErrorCount,Delay,Expires,Priority,Item}, _From, {HC,HOffset, TOffset, Tcount,CurrOpen,FRef,Mf,MfRef}) ->

	Pname=Pname, Qname=Qname, ErrorCount=ErrorCount,Delay=Delay,Expires=Expires,Item=Item,Priority=Priority,
	
	FIndex=Tcount div 2,
	TFIndex=integer_to_list(FIndex), %convert to text
	
	TPriority=integer_to_list(Priority),
	MToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<".etm">>]),
	ToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<"-">>,TFIndex,<<".et">>]),

	
	{RRef,NOffset}= case CurrOpen==ToBeOpen of
	
	true -> {FRef,TOffset};
	false -> 
		{ok, NFRef} = file:open(ToBeOpen, [read, write, raw, binary]),
		{NFRef,0}
	end,
	
	ItemSize= byte_size(Item),

	NItem = iolist_to_binary([<<ErrorCount:64>>,<<Expires:64>>,<<ItemSize:32>>,Item]),
	
	NTOffset = NOffset + byte_size(NItem),
	
	file:pwrite(RRef,NOffset,NItem),
	
	NTCount = Tcount + 1,
	

	RMfRef = case MToBeOpen==Mf of
	
	true -> MfRef;
	false -> 
		{ok, NMfRef} = file:open(MToBeOpen, [read, write, raw, binary]),
		NMfRef =NMfRef
	end,

	Contents = iolist_to_binary([<<NTCount:64>>]),
	file:pwrite(RMfRef,16,Contents),

	
	
	io:format("\n ~p ~p ~p ~p ~p ~p ~p ~p",[HC,HOffset, NTOffset, NTCount,ToBeOpen,RRef,MToBeOpen,RMfRef]),
  {reply, ok,  {HC,HOffset, NTOffset, NTCount,ToBeOpen,RRef,MToBeOpen,RMfRef}};


handle_call({lfd,Pname,Qname,Priority}, _From, _) ->

		TPriority=integer_to_list(Priority),
		MToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<".etm">>]),
		{ok, NMfRef} = file:open(MToBeOpen, [read, write, raw, binary]),
		{ok, Data}= file:pread(NMfRef,0,24),
		<<NHC:64>> = binary:part(Data,0,8),
		<<NHOffset:64>> = binary:part(Data,8,8),
		<<NTCount:64>> = binary:part(Data,16,8),	
		
		FIndex	= case NTCount rem 2 of 
				0 -> (NTCount div 2) -1 ;
				_ -> (NTCount div 2)
				end,

		TFIndex=integer_to_list(FIndex), %convert to text		
		ToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<"-">>,TFIndex,<<".et">>]),
		{ok, RRef} = file:open(ToBeOpen, [read, write, raw, binary]),
		NTOffset=filelib:file_size(ToBeOpen),

io:format("\n ~p ~p ~p ~p ~p ~p ~p ~p",[NHC,NHOffset, NTOffset, NTCount,ToBeOpen,RRef,MToBeOpen,NMfRef]),
  {reply, ok,  {NHC,NHOffset, NTOffset, NTCount,ToBeOpen,RRef,MToBeOpen,NMfRef}};


handle_call({pop,Pname,Qname,Priority}, _From,  {HC,HOffset, TOffset, TCount,CurrOpen,FRef,Mf,MfRef}) ->


		FIndex=HC div 2,
		TFIndex=integer_to_list(FIndex), %convert to text
		TPriority=integer_to_list(Priority),
		ToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<"-">>,TFIndex,<<".et">>]),
		MToBeOpen = iolist_to_binary([<<"ext/data/">>,Pname,<<"/">>,Qname,<<"-">>,TPriority,<<".etm">>]),

		
		

		% setting the ET file pointer
		{Status,RRef,TNHOffset} = case CurrOpen==ToBeOpen of
				
				true -> {ok,FRef,HOffset};
				
				false -> 
					case  file:open(ToBeOpen, [read,write, raw, binary]) of
					{ok,NFRef}->{ok,NFRef,0};
					_ -> {error,FRef,HOffset}
				end
		end,



		{_,RData,NHC,NHOffset,RMfRef} = case Status of 


			ok ->

					%Retrivies the first Item header from offset from ET file
					 case file:pread(RRef,TNHOffset,20)  of
						

						{ok,Data} -> 

								% get item length
								<<ItemLen:32>> = binary_part(Data,16,4),
								{ok,Item} = file:pread(RRef,TNHOffset+20,ItemLen),

								% Update meta data
								
								% seeting the ETM file pointer
								TRMfRef = case MToBeOpen==Mf of
								
									true -> MfRef;
									
									false -> 
										{ok, NMfRef} = file:open(MToBeOpen, [read, write, raw, binary]),
										NMfRef =NMfRef
								end,


								TNHC = HC +1,
								T_NHOffset = TNHOffset + 20 + ItemLen,
								Contents = iolist_to_binary([<<TNHC:64>>,<<T_NHOffset:64>>]),
								file:pwrite(TRMfRef,0,Contents),
								
						

								{ok,Item,TNHC,T_NHOffset,TRMfRef};


						
						_ -> 
								TRMfRef = case MToBeOpen==Mf of
								
									true -> MfRef;
									
									false -> 
										{ok, NMfRef} = file:open(MToBeOpen, [read, write, raw, binary]),
										NMfRef = NMfRef
								end,		

							{error,no_item,HC,TNHOffset,TRMfRef}



					end;

		_ ->



			TRMfRef = case MToBeOpen==Mf of
		
			true -> MfRef;
			
			false -> 
				{ok, NMfRef} = file:open(MToBeOpen, [read, write, raw, binary]),
				NMfRef =NMfRef
			end,
			{error,no_item,HC,TNHOffset,TRMfRef}

		end,

io:format("\n ~p ~p ~p ~p ~p ~p ~p ~p",[NHC,NHOffset, TOffset, TCount,ToBeOpen,RRef,MToBeOpen,RMfRef]),

{reply, RData,  {NHC,NHOffset, TOffset, TCount,ToBeOpen,RRef,MToBeOpen,RMfRef}};


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


