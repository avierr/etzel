ERL_CFLAGS = -finline-functions -Wall -fPIC -I /usr/local/Cellar/erlang/18.1/lib/erlang/erts-7.1/include -I /usr/local/Cellar/erlang/18.1/lib/erlang/lib/erl_interface-3.8/include
ERL_LDFLAGS = -L /usr/local/Cellar/erlang/18.1/lib/erlang/lib/erl_interface-3.8/lib -lerl_interface -lei

DRV_LDFLAGS = -flat_namespace -undefined suppress $(ERL_LDFLAGS)
CFLAGS =  -DSQLITE_THREADSAFE=1 -DSQLITE_USE_URI -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS

LDFLAGS += -flat_namespace -undefined suppress

all:: priv/esqlite3_nif.so

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.C
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cc
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cpp
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

priv/esqlite3_nif.so: $(foreach ext,.c .C .cc .cpp,$(patsubst %$(ext),%.o,$(filter %$(ext),$(wildcard c_src/esqlite3_nif.c c_src/queue.c c_src/sqlite3.c))))
	$(CC) -o $@ $? $(LDFLAGS) $(ERL_LDFLAGS) $(DRV_LDFLAGS) $(EXE_LDFLAGS) -shared
