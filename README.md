# Etzel

![Etzel Build Status](https://travis-ci.org/evnix/etzel.svg?branch=master)

Website: http://etzelserver.aviscript.ml

A Fast & Reliable open source Job delegation & queueing server.

Etzel is built for Robust messaging between applications. It has built-in support for load-balancing and fault tolerance.

- Build distributed applications that scale right from the start
- Build applications that have no single point of failure
- Decouple your program into components written in languages best suited for the task

````
The program is currently under development. check back soon!

currently to be developed:

Delete
Acknowledge
Disk Logging

.  ~/test/er18/activate
 ./_rel/etzel_release/bin/etzel_release console

````


````
> cd test
> python -m SimpleHTTPServer 9000

Goto: http://localhost:9000/push.html 
then Goto: http://localhost:9000/push.html

````


````

EtzelDisk Test Sequence:

{ok,P}=etzeldisk:start_link().
gen_server:call(P,{push,<<"P1">>,<<"Q1">>,0,0,0,0,<<"hi">>}).


{ok,P}=etzeldisk:start_link().
gen_server:call(P,{lfd,<<"P1">>,<<"Q1">>,0}).


{ok,P}=etzeldisk:start_link().
gen_server:call(P,{pop,<<"P1">>,<<"Q1">>,0}).

````

````
ServerManager Test Sequence

datamanager:start_link().
servermanager:start_link().
gen_server:call(whereis(servermanager),{register_user,<<"aabc">>,"1234"}).

````
