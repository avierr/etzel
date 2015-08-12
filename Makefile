PROJECT = hi
DEPS = cowboy jiffy eleveldb erlang-uuid
dep_erlang-uuid = git https://github.com/avtobiff/erlang-uuid.git master
include erlang.mk


export ERL_COMPILER_OPTIONS=nowarn_deprecated_function
