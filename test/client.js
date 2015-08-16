etzelclient=require("./etzelclient.js");

ec=new etzelclient("ws://localhost:8080/connect");

//for(i=0;i<10000;i++)

ec.onopen=function(){

    // i=0;
    // pw.publish('test1','hi');
    ec.publish('test1','hi',{delay:5});

}

console.log("completed.");
