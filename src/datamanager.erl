-module(datamanager).

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

-define(METADATA_PATH,element(2,application:get_env(etzel,metadata_path))).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
  %say("\nFilegen: Persistance Server Initiated. \n", []),
  random:seed(erlang:now()),
  Db=iolist_to_binary([?METADATA_PATH,<<"data.db">>]),
  {ok, Ref} = esqlite3:open(binary_to_list(Db)),
  {ok, {Ref}}.



handle_call({put_user,Email,Password,Salt},_From,{Ref}) ->

    {ok, Statement} = esqlite3:prepare(<<"INSERT INTO users(username,password,salt) VALUES (?,?,?)">>,Ref),
    esqlite3:bind(Statement, [Email, Password,Salt]),
    Res=esqlite3:step(Statement),

    io:format("pass: ~p \n END",[Password]),

    %filelib:ensure_dir("hey/boe/cey/"),
    Reply = Res,
    {reply,Reply,{Ref}};

handle_call({get_user,Email,Password},_From,{Ref}) ->

    Res = esqlite3:q(<<"SELECT count(type) FROM sqlite_master WHERE username=? AND password=?;">>, [Email,Password], Ref),
    Res=Res,
    %filelib:ensure_dir("hey/boe/cey/"),
    Reply = 1,
    Email=Email,
    Password=Password,

    {reply,Reply,{Ref}};

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


