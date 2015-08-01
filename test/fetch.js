ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");

for(i=0;i<1000;i++)
pw.fetch('test1');
