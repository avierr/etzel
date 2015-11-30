PROJECT = etzel
DEPS = cowboy jiffy eleveldb mustache esqlite
dep_esqlite = git https://github.com/mmzeeman/esqlite master
include erlang.mk



export ERL_COMPILER_OPTIONS=nowarn_deprecated_function

all::
	cp -r ext _rel/etzel_release


