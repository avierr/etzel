# Etzel

The program is currently under development. check back soon!

currently to be developed:

Delete
Acknowledge
Disk Logging

.  ~/test/er18/activate
 ./_rel/etzel_release/bin/etzel_release console


````
> cd test
> python -m SimpleHTTPServer 9000

Goto: http://localhost:9000/push.html 
then Goto: http://localhost:9000/push.html

````


EtzelDisk Test Sequence:

{ok,P}=etzeldisk:start_link().
gen_server:call(P,{push,<<"P1">>,<<"Q1">>,0,0,0,0,<<"hi">>}).


{ok,P}=etzeldisk:start_link().
gen_server:call(P,{lfd,<<"P1">>,<<"Q1">>,0}).


{ok,P}=etzeldisk:start_link().
gen_server:call(P,{pop,<<"P1">>,<<"Q1">>,0}).

````