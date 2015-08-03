if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    var WebSocket = require('ws');


ParaComputeD = function(host) {

    this.ws = new WebSocket(host);
    this.opened = false;
    this.queue = [];
    this.qbacks = {};
    this.ws.paraParent = this;
    this.ws.onmessage = this.onmessage;
    this.ws.onopen = this.onopen;
    this.onopen=null;


};


ParaComputeD.prototype.isleep = function(qname) {
   

    var Obj = new Object();
    Obj.qname = qname;
    Obj.cmd = "ISLP";
    var data = JSON.stringify(Obj);
    console.log(Obj.qname + Obj.cmd);
    this.ws.send(data);

};
//var sendserver=func


ParaComputeD.prototype.onopen = function(evt) {

    //console.log(evt);
    this.opened = true;
    this.paraParent.onopen();
    

};

j = 1;
ParaComputeD.prototype.onmessage = function(evt) {

    console.log(evt.data);
    console.log(j++);
    d = JSON.parse(evt.data);

    if (typeof d.msg !== 'undefined') {
        // the variable is defined

        console.log("================Done==========");
    }
    if (d.cmd == "awk")
        this.paraParent.fetch(d.qname); //"this" is inside ws.onmessage scope. we need parent scope which is in the constructor :)
    if (d.cmd == 'nomsg') {
        this.paraParent.isleep(d.qname);

    }
    if(d.cmd=="msg"){
        this.paraParent.qbacks[d.qname](d.msg);
         this.paraParent.fetch(d.qname);
    }


};

ParaComputeD.prototype.publish = function(queue, msg, options) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.msg = msg;
    Obj.cmd = "PUB";
    Obj.delay= 0;

    if((typeof options !== 'undefined') && (typeof options.delay !== 'undefined')){

        Obj.delay = options.delay;
    }

    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

ParaComputeD.prototype.sendSubCmd = function(queue) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.cmd = "SUB";
    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

ParaComputeD.prototype.fetch = function(queue) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.cmd = "FET";
    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

ParaComputeD.prototype.subscribe = function(queue, callback) {

    this.sendSubCmd(queue); //we have to notify the server that we are subscribing
    this.qbacks[queue] = callback;
    this.fetch(queue);

};


if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    module.exports = ParaComputeD;
else
    window.ParaComputeD = ParaComputeD;
