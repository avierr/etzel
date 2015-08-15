etzelclient=require("./etzelclient.js");

ec=new etzelclient("ws://localhost:8080/connect");


function mycallback(data){

    console.log(data+" from the queue");

}


ec.onopen=function(){


    ec.subscribe("test1",mycallback);

}





