ERL_CFLAGS = -finline-functions -Wall -fPIC -I /usr/local/Cellar/erlang/18.1/lib/erlang/erts-7.1/include -I /usr/local/Cellar/erlang/18.1/lib/erlang/lib/erl_interface-3.8/include
ERL_LDFLAGS = -L /usr/local/Cellar/erlang/18.1/lib/erlang/lib/erl_interface-3.8/lib -lerl_interface -lei

DRV_LDFLAGS =  c_src/leveldb/libleveldb.a c_src/system/lib/libsnappy.a -lstdc++ -mmacosx-version-min=10.8
DRV_CFLAGS =  -O3 -Wall -I c_src/leveldb/include -mmacosx-version-min=10.8
CXXFLAGS =  -Wall -O3 -fPIC -mmacosx-version-min=10.8
CFLAGS =  -Wall -O3 -fPIC -mmacosx-version-min=10.8

LDFLAGS += -flat_namespace -undefined suppress

all:: priv/eleveldb.so

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.C
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cc
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cpp
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

priv/eleveldb.so: $(foreach ext,.c .C .cc .cpp,$(patsubst %$(ext),%.o,$(filter %$(ext),$(wildcard c_src/*.cc))))
	$(CC) -o $@ $? $(LDFLAGS) $(ERL_LDFLAGS) $(DRV_LDFLAGS) $(EXE_LDFLAGS) -shared
