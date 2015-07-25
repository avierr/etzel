var WebSocket = require('ws');

// Let us open a web socket
var ws = new WebSocket("ws://localhost:8080/connect");

ws.onopen = function()
{
  // Web Socket is connected, send data using send()
  ws.send('{"cmd": "SUBx"}');
  console.log("Message is sent...");
};

ws.onmessage = function (evt) 
{ 
  var received_msg = evt.data;
  console.log("Message is received..."+received_msg);
};

ws.onclose = function()
{ 
  // websocket is closed.
  console.log("Connection is closed..."); 
};



