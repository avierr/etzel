ERL_CFLAGS = -finline-functions -Wall -fPIC -I /usr/lib/erlang/erts-7.0/include -I /usr/lib/erlang/lib/erl_interface-3.8/include
ERL_LDFLAGS = -L /usr/lib/erlang/lib/erl_interface-3.8/lib -lerl_interface -lei

CFLAGS =  -Wall -O3 -fPIC
CXXFLAGS =  -Wall -O3 -fPIC
DRV_CFLAGS =  -O3 -Wall -I c_src/leveldb/include
DRV_LDFLAGS =  c_src/leveldb/libleveldb.a c_src/system/lib/libsnappy.a -lstdc++

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
