import json
import asyncio
import websockets


class etzelclient (host):
    def __init__(self):
        self.ws = yield from websockets.connect(host)
        self.opened = false
        self.queue = []
        self.qbacks = {}
        self.ws.etzelParent = self
        self.ws.onmessage = self.onmessage
        self.ws.onopen = self.onopen
        self.onopen = None

    def isleep(qname):
        content = {
            "qname": qname,
            "cmd": "ISLP"
        }
        data = json.JSONEncoder().encode(content)
        yield from self.ws.send(data)


    def onopen(evt):
        self.opened = true
        self.etzelParent.onopen()
    
    def onmessage(evt):
        d = json.JSONDecoder(evt.data)

        if ("msg" in d):
            #the variable is not defined

        if (d["cmd"] == "awk"):
            self.etzelParent.fetch(d["qname"])
            #"self" is inside ws.onmessage scope. we need parent scope which is in the constructor :)
        elif (d["cmd"] == "nomsg"):
            self.etzelParent.isleep(d["qname"])
        elif (d["cmd"] == "msg"):
            self.etzelParent.qbacks[d["qname"]](d)
            self.etzelParent.fetch(d["qname"])


    def publish(queue, msg, options=None):

        content = {
            "qname" : queue,
            "msg" : msg,
            "cmd" : "PUB",
            "delay" : 0,
            "expires" : 0
        }

        if(options != None) && ("delay" in options)){

            content["delay"] = options["delay"]
        }

        if(options != None) && ("expires" in options)){

            content["expires"] = options["expires"]
        }

        data = json.JSONEncoder().encode(content)
        yield from self.ws.send(data)

    def sendSubCmd(queue):
        content = {
            "qname" = queue,
            "cmd" = "SUB"
        }
        
        data = json.JSONEncoder().encode(content)
        yield from self.ws.send(data)


    def acknowledge(queue,uid):
        content = {
            "qname" = queue,
            "cmd" = "ACK",
            "uid" = uid
        }
        
        data = json.JSONEncoder().encode(content)
        yield from self.ws.send(data)

    def fetch(queue):
        content = {
            "qname" = queue,
            "cmd" = "FET"
        }

        data = json.JSONEncoder().encode(content)
        yield from self.ws.send(data)
    
    def subscribe(queue, callback):
        self.sendSubCmd(queue) #we have to notify the server that we are subscribing
        self.qbacks[queue] = callback
        self.fetch(queue)