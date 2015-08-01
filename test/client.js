ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");

//for(i=0;i<10000;i++)

pw.onopen=function(){

    i=0;
    pw.publish('test1','hi'+i);

}

console.log("completed.");
