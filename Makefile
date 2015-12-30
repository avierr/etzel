PROJECT = etzel
DEPS = cowboy jiffy eleveldb mustache esqlite
DEPS = cowboy jiffy eleveldb esqlite cowboy_session
#dep_esqlite = git https://github.com/mmzeeman/esqlite master
#dep_cowboy_session = git https://github.com/chvanikoff/cowboy_session master
include erlang.mk
export ERL_COMPILER_OPTIONS=nowarn_deprecated_function

all::
	cp -r ext _rel/etzel_release


