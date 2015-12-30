ERL_CFLAGS = -finline-functions -Wall -fPIC -I /usr/lib/erlang/erts-7.0/include -I /usr/lib/erlang/lib/erl_interface-3.8/include
ERL_LDFLAGS = -L /usr/lib/erlang/lib/erl_interface-3.8/lib -lerl_interface -lei

CFLAGS =  -Ic_src/ -g -Wall  -O3 -fno-strict-aliasing
CXXFLAGS =  -Ic_src/ -g -Wall  -O3
LDFLAGS =  -lstdc++

all:: priv/jiffy.so

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.C
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cc
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

%.o: %.cpp
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(ERL_CFLAGS) $(DRV_CFLAGS) $(EXE_CFLAGS)

priv/jiffy.so: $(foreach ext,.c .C .cc .cpp,$(patsubst %$(ext),%.o,$(filter %$(ext),$(wildcard c_src/*.c c_src/*.cc c_src/double-conversion/*.cc))))
	$(CC) -o $@ $? $(LDFLAGS) $(ERL_LDFLAGS) $(DRV_LDFLAGS) $(EXE_LDFLAGS) -shared
