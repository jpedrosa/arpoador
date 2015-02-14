
var net = require('net');

var port = 8780;

function handleServerSocket(client) {
  client.on("data", function(chunk) {
      var body = "Some <b>sample</b> text.",
        header = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: ",
        s = "" + header + body.length + "\n\n" + body;
      client.write(s);
      client.destroy();
      });
}

function handleServerStartup() {
  console.log("Starting server on port " + port + ".");
}

var server = net.createServer(handleServerSocket).listen(port,
   handleServerStartup);
