

#Nodejs & javascript client for Etzel server:-

You can install the node client by opening a command prompt and using the following command

````
npm install etzelclient
````

then include the library in your .js file:

````
require('etzelclient');
````

#### 1. publish(queuename,message,options)

This pushes a message to etzel server.The arguments required are queuename (which is the name of the queue you want to pubish to), message (which is the message you want to publish to the queue),options includes delay and expire functionality . The options argument  can be used when the message insert needs to be delayed or messaged validity needs to be expired. Options isn't an obligatory argument. The delay and expiry is taken in seconds.

Example:-
````
etzelclient=require("etzelclient");

ec=new etzelclient("ws://localhost:8080/connect");
ec.onopen=function(){
    ec.publish('test','hi');

}
````

test is the queuename,hi is the message and the delay is 0 seconds

additional options for publish:

````
    ec.publish('test','hi',{delay:5,expires:3600,priority:0});
````

* `delay`: The item will not be available on the queue until this many seconds have passed.
Default is 0 seconds. Maximum is 365 days(in seconds).

* `expires`: How long in seconds to keep the item on the queue before it is deleted.
Default is 0(365 days).

* `priority`: It can be either -20,0,20 (High, Medium, Low).


#### 2. subscribe(queuename,callback)

The subscribe function is fetches a message from the etzel server. The argument required are queuename which is the name of the you want to fetch the data from, callback is a custom fucntion which you have you provide. 


Example:-

````
etzelclient=require("etzelclient");

ec=new etzelclient("ws://localhost:8080/connect");

//function which the end user writes
function mycallback(data){

    console.log(data.msg+" from the queue");
    ec.acknowledge("test",data.uid);

}
ec.onopen=function(){
    ec.subscribe("test",mycallback);
}

````
Here test is the queuename.
An entity fetching data from the specific queue is called a worker. You can multiple workers working on the same queue. The server facilitates load balancing amongst the workers. Fetching a message will delete the message from the queue **temporarily**(re-queued after 60 seconds). 

acknowledge(queuename,uid)

To delete it permanently , we use the acknowledge function which deletes/acknowledges a specific message from the queue. The arguments required are queuename and the id of the message you want to acknowledge.



### Responses received from the queue are as follows:-

The responses received are all in standard json format.


#### No Queue Found:-

````
{
    "cmd":"nok",
    "err": "Q_NOT_FOUND"
}
```

#### No Message Available in the requested Queue:-

````
{
    "cmd":"nomsg",
    "qname": "$Q_NAME"
}
````

#### Server says it is OK to go to sleep

````
{
    "cmd":"okslp",
    "qname": "$Q_NAME"
}
````

#### Message Available in the requested Queue:-

````
{
    "cmd": "msg",
    "qname": "$Q_NAME",
    "uid": "$uid",
    "error_count": "$count",
    "msg": "$message"
}
````

#### Queue is awake:-

````
{
    "cmd":"awk",
    "qname": "$Q_NAME"
}
````
