PROJECT = etzel
DEPS = cowboy jiffy eleveldb erlydtl
include erlang.mk



export ERL_COMPILER_OPTIONS=nowarn_deprecated_function

all::
	cp -r ext _rel/etzel_release


