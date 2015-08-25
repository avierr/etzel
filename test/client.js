etzelclient=require("./etzelclient.js");

ec=new etzelclient("ws://localhost:8080/connect");

 ec.onopen=function(){
for(i=0;i<1000000;i++){

	ec.publish("test1",i);
	if(i%10000==0){

		console.log(i);
	}
}
}
// ec.onopen=function(){

//     // i=0;
//     // pw.publish('test1','hi');
//     ec.publish('test1','hi',{delay:5});

// }

console.log("completed.");
