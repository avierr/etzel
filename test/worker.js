ParaComputeD=require("./ParaComputeD.js");

pw=new ParaComputeD("ws://localhost:8080/connect");


function mycallback(data){

    console.log(data);

}


pw.onopen=function(){


    pw.subscribe("test1");

}





