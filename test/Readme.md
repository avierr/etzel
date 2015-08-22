

#Nodejs and javascript client for Etzel server:-

You can install the node client by opening a command prompt and using the following command
#####npm install etzelclient

You must then include the library in your .js file by using the require function.
#####require('etzelclient');
##The following functions are available to connect to etzel server:-

###1.publish(queuename,message,options)- This pushes a message to etzel server.The arguments required are queuename (which is the name of the queue you want to pubish to), message (which is the message you want to publish to the queue),options includes delay and expire functionality . The options argument  can be used when the message insert needs to be delayed or messaged validity needs to be expired. Options isn't an obligatory argument. The delay and expiry is taken in seconds.

Example:-
etzelclient=require("etzelclient");

ec=new etzelclient("ws://localhost:8080/connect");
ec.onopen=function(){
    ec.publish('test','hi',{delay:5});

}
test is the queuename,hi is the message and the delay is 5 seconds


###2.subscribe(queuename,callback)- The subscribe function is fetches a message from the etzel server. The argument required are queuename which is the name of the you want to fetch the data from, callback is a custom fucntion which you have you provide. 


Example:-
etzelclient=require("etzelclient");

ec=new etzelclient("ws://localhost:8080/connect");

//function which the end user writes
function mycallback(data){

    console.log(data+" from the queue");

}
ec.onopen=function(){
    ec.subscribe("test",mycallback);
}
Here test is the queuename.
An entity fetching data from the specific queue is called a worker. You can multiple workers working on the same queue. The server facilitates lodbalancing amongst the workers. Fetching a message will delete the message from the queue.




###3.acknowledge(queuename,uid)- The acknowledge function acknowledges a specific message from the queue. The arguments required are queuename and the id of the message you want to acknowledge.
 etzelclient=require("etzelclient");

ec=new etzelclient("ws://localhost:8080/connect");

//function which the end user writes
function mycallback(data){

    console.log(data+" from the queue");

}
ec.onopen=function(){
    ec.acknowledge("test",1);
}

Here test is the queuename and uuid is the message specific and in this case its 1.




##Responses received from the queue are as follows:-
The responses received are all in standard json format.

###No Queue Found:-
{
    "cmd":"nok",
    "err": "Q_NOT_FOUND"
}
###No Message Available in the requested Queue:-
{
    "cmd":"nomsg",
    "qname": "$Q_NAME"
}
###Queue goes to sleep because there are no messages present-
{
    "cmd":"okslp",
    "qname": "$Q_NAME"
}
###Message Available in the requested Queue:-
{
    "cmd": "msg",
    "qname": "$Q_NAME",
    "uid": "$uid",
    "error_count": "$count",
    "msg": "$message"
}
###queue is awake:-
{
    "cmd":"awk",
    "qname": "$Q_NAME"
}
