PROJECT = etzel
DEPS = cowboy jiffy eleveldb dtl
include erlang.mk



export ERL_COMPILER_OPTIONS=nowarn_deprecated_function

all::
	cp -r ext _rel/etzel_release


