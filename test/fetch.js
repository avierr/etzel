etzelclient=require("./etzelclient.js");

ec=new etzelclient("ws://localhost:8080/connect");

//for(i=0;i<1000;i++)
ec.fetch('test1');
