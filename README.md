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


````

{ok,P2}=etzeldisk:start_link()
gen_server:call(P2,{push,<<"p1">>,<<"q1">>,0,0,0,0,<<"hi">>}).

````