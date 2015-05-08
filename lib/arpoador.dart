library arpoador;

import 'dart:io';
import 'dart:typed_data';


class Momentum {

  static listen({port: 8777, address: "127.0.0.1",
      handler(socket)}) {
    var server = new ServerSocket(address, port);
    while (true) {
      server.spawnAccept(handler);
    }
  }

  static handle(socket, fn(req, res)) {
    var buffer = socket.readNext();
    if (buffer != null) {
      var response = new Response(socket);
      fn(new Request(), response);
      response.doFlush();
    }
    socket.close();
  }

}


class Request {

}

class Response {

  var socket, statusCode = 200, headerMap = {}, responseContent = "";

  Response(this.socket);

  writeHead(statusCode, headerMap) {
    this.statusCode = statusCode;
    this.headerMap = headerMap;
  }

  end(responseContent) {
    this.responseContent = responseContent;
  }

  doFlush() {
    var body = responseContent,
      header = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: ",
      s = "${header}${body.length}\n\n${body}";
    var len = s.length, i, a = new Uint8List(len);
    for (i = 0; i < len; i++) {
      a[i] = s.codeUnitAt(i);
    }
    socket.write(a.buffer);
  }

}
