var WebSocket = require('ws');


ParaComputeD=function(host){
       
   this.ws = new WebSocket(host);
   this.opened=false;
   this.queue=[];
   this.qbacks={};
   this.ws.paraParent=this;
   this.ws.onmessage=this.onmessage;
   this.ws.onopen=this.onopen;
   
   
};

ParaComputeD.prototype.lateSend=function(){

   while(this.queue.length>0){
   
    this.ws.send(this.queue.shift());
   
   }

};


ParaComputeD.prototype.onopen = function(evt) {

    //console.log(evt);
  this.opened=true;
  this.paraParent.lateSend();
        
};


ParaComputeD.prototype.onmessage = function(evt) {

  //console.log(evt.data);
  d=JSON.parse(evt.data);

  if (typeof d.msg !== 'undefined') {
    // the variable is defined
    if(d.msg=="hi9999")
  console.log("================Done==========");  
}
   

};

ParaComputeD.prototype.publish = function(queue,msg) {

    var Obj=new Object();
    Obj.qname=queue;
    Obj.msg=msg;
    Obj.cmd="PUB";
    var data=JSON.stringify(Obj);
    
    if(this.opened==false){
    
    //if connection is not open, 
    //push it to Q & send it later using lateSend()
        this.queue.push(data);
    
    }else{
    
        this.ws.send(data);
    
    }
    
        
};


ParaComputeD.prototype.fetch = function(queue) {

    var Obj=new Object();
    Obj.qname=queue;
    Obj.cmd="FET";
    var data=JSON.stringify(Obj);
    
    if(this.opened==false){
    
    //if connection is not open, 
    //push it to Q & send it later using lateSend()
        this.queue.push(data);
    
    }else{
    
        this.ws.send(data);
    
    }
    
        
};

ParaComputeD.prototype.subscribe = function(queue,callback) {


    this.qbacks[queue]=callback;
    var Obj=new Object();
    Obj.qname=queue;
    Obj.cmd="SUB";
     var data=JSON.stringify(Obj);
    
    if(this.opened==false){
    
    //if connection is not open, 
    //push it to Q & send it later using lateSend()
        this.queue.push(data);
    
    }else{
    
        this.ws.send(data);
    
    }
        
};

if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    module.exports = ParaComputeD;
else
    window.ParaComputeD = ParaComputeD;

