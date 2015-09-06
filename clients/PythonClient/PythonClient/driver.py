import json
import asyncio
import websockets

class etzelclient ():
    host = "localhost"
    port = "8765"
    
    def __init__(self):
        self.opened = False
        self.queue = []
        self.qbacks = {}

    @asyncio.coroutine
    def sendTo(self, data):
        websocket = yield from websockets.connect('ws://'+host+':'+port+'/')
        yield from websocket.send(data)
        yield from websocket.close()

    def isleep(self, qname):
        content = {
            "qname": qname,
            "cmd": "ISLP"
        }
        data = json.JSONEncoder().encode(content)
        websocket.send(data)

    @asyncio.coroutine
    def worker(self):
        websocket = yield from websockets.connect('ws://'+host+':'+port+'/')
        evt = yield from websocket.recv()
        d = json.JSONDecoder().decode(evt)

        if (d["cmd"] == "awk"):
            self.fetch(d["qname"])
        elif (d["cmd"] == "nomsg"):
            self.isleep(d["qname"])
        elif (d["cmd"] == "msg"):
            self.qbacks[d["qname"]](d)
            self.fetch(d["qname"])

        yield from websocket.close()


    def publish(self, queue, msg, options=None):

        content = {
            "qname" : queue,
            "msg" : msg,
            "cmd" : "PUB",
            "delay" : 0,
            "expires" : 0
        }

        if ((options != None) and ("delay" in options)):
            content["delay"] = options["delay"]

        if ((options != None) and ("expires" in options)):
            content["expires"] = options["expires"]

        data = json.JSONEncoder().encode(content)
        sendTo(data)

    def sendSubCmd(self, queue):
        content = {
            "qname" : queue,
            "cmd" : "SUB"
        }
        
        data = json.JSONEncoder().encode(content)
        sendTo(data)


    def acknowledge(self, queue, uid):
        content = {
            "qname" : queue,
            "cmd" : "ACK",
            "uid" : uid
        }
        
        data = json.JSONEncoder().encode(content)
        sendTo(data)

    def fetch(self, queue):
        content = {
            "qname" : queue,
            "cmd" : "FET"
        }

        data = json.JSONEncoder().encode(content)
        sendTo(data)
    
    def subscribe(self, queue, callback):
        self.sendSubCmd(queue) #we have to notify the server that we are subscribing
        self.qbacks[queue] = callback
        self.fetch(queue)

    def startwolf(self):
        asyncio.get_event_loop().run_until_complete(self.worker())