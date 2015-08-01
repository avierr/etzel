ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");
i=0;
//for(i=0;i<10000;i++)

pw.publish('test1','hi'+i);


console.log("completed.");
