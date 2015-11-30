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
         code_change/3]).

-define(DATA_PATH,element(2,application:get_env(etzel,data_path))).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
   
  io:format("\nServerManager Process Initiated. \n", []),
  random:seed(erlang:now()),
    Ref=1,
  {ok, {Ref}}.


handle_call({login_user,Email,Password},_From,{Prefix}) ->

    %filelib:ensure_dir("hey/boe/cey/"),
    Res = gen_server:call(whereis(datamanager),{get_user,Email}),

    Reply = case Res of
            
            [] -> {error,err_UDNE,<<"username does not exist">>};
            
            _ ->
            
                [{Id,Username,DBPassword,DBSalt}] = Res,
                BoolRes = commonlib:check_pass(Password,DBPassword,DBSalt),
                
                case BoolRes of 
                    true -> 
                            {ok,Id,Username};
                    false ->
                            {error,err_UPDNE,<<"Username or Password does not match">>}

                end

            end,   


    {reply,Reply,{Prefix}};

handle_call({register_user,Email,Password},_From,{Prefix}) ->

    %filelib:ensure_dir("hey/boe/cey/"),
    {Hash,Salt}=commonlib:hash_pass(Password),
    Reply=gen_server:call(whereis(datamanager),{put_user,Email,Hash,Salt}),
    {reply,Reply,{Prefix}};

handle_call(create_proj_dir,_From,{Prefix}) ->

    filelib:ensure_dir("hey/boe/cey/"),
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



%% Internal functions
