ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");
pw.publish('test1','hi');
