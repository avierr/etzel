if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    var WebSocket = require('ws');


etzelclient = function(host) {

    this.ws = new WebSocket(host);
    this.opened = false;
    this.queue = [];
    this.qbacks = {};
    this.ws.etzelParent = this;
    this.ws.onmessage = this.onmessage;
    this.ws.onopen = this.onopen;
    this.onopen=null;


};


etzelclient.prototype.isleep = function(qname) {
   

    var Obj = new Object();
    Obj.qname = qname;
    Obj.cmd = "ISLP";
    var data = JSON.stringify(Obj);
   // console.log(Obj.qname + Obj.cmd);
    this.ws.send(data);

};


etzelclient.prototype.onopen = function(evt) {

    //console.log(evt);
    this.opened = true;
    this.etzelParent.onopen();
    

};

j = 1;
etzelclient.prototype.onmessage = function(evt) {

    //console.log(evt.data);
   // console.log(j++);
    d = JSON.parse(evt.data);

    if (typeof d.msg !== 'undefined') {
        // the variable is defined

        //console.log("================Done==============");
    }
    if (d.cmd == "awk")
        this.etzelParent.fetch(d.qname); //"this" is inside ws.onmessage scope. we need parent scope which is in the constructor :)
    if (d.cmd == 'nomsg') {
        this.etzelParent.isleep(d.qname);

    }
    if(d.cmd=="msg"){
        this.etzelParent.qbacks[d.qname](d);
         this.etzelParent.fetch(d.qname);
    }


};

etzelclient.prototype.publish = function(queue, msg, options) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.msg = String(msg);
    Obj.cmd = "PUB";
    Obj.delay= 0;
    Obj.expires=0;

    if((typeof options !== 'undefined') && (typeof options.delay !== 'undefined')){

        Obj.delay = options.delay;
    }

    if((typeof options !== 'undefined') && (typeof options.expires !== 'undefined')){

        Obj.expires = options.expires;
    }

    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

etzelclient.prototype.sendSubCmd = function(queue) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.cmd = "SUB";
    var data = JSON.stringify(Obj);
    this.ws.send(data);

};


etzelclient.prototype.acknowledge = function(queue,uid) {

    var Obj = new Object();
    Obj.qname = queue;
    Obj.cmd = "ACK";
    Obj.uid= uid;
    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

etzelclient.prototype.fetch = function(queue) {


    var Obj = new Object();
    Obj.qname = queue;
    Obj.cmd = "FET";
    var data = JSON.stringify(Obj);
    this.ws.send(data);

};

etzelclient.prototype.subscribe = function(queue, callback) {

    this.sendSubCmd(queue); //we have to notify the server that we are subscribing
    this.qbacks[queue] = callback;
    this.fetch(queue);

};


if (typeof module !== 'undefined' && typeof module.exports !== 'undefined')
    module.exports = etzelclient;
else
    window.etzelclient = etzelclient;
