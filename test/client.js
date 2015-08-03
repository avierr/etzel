ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");

//for(i=0;i<10000;i++)

pw.onopen=function(){

    // i=0;
    // pw.publish('test1','hi');
    pw.publish('test1','hi',{delay:5});

}

console.log("completed.");
