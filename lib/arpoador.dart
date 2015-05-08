library arpoador;

import 'dart:io';
import 'dart:typed_data';


class Momentum {

  /// For now, the handler callback should be a static method or function.
  /// It seems that instance methods don't work as handler callbacks yet.
  static listen({port: 8777, address: "127.0.0.1", handler(socket)}) {
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

  var socket, statusCode = 200, headerMap = const {"Content-Type": "text/html"},
    responseContent = "";

  Response(this.socket);

  writeHead(statusCode, headerMap) {
    this.statusCode = statusCode;
    this.headerMap = headerMap;
  }

  end(responseContent) {
    this.responseContent = responseContent;
  }

  concatHeaderMap() {
    var s = "", kk = headerMap.keys, k;
    for (k in kk) {
      s += "${k}: ${headerMap[k]}\n";
    }
    return s;
  }

  doFlush() {
    var body = responseContent,
      s = "HTTP/1.1 ${statusCode} ${statusCodeList[statusCode]}"
        "\n${concatHeaderMap()}Content-Length: ${body.length}\n\n${body}",
      len = s.length, i, a = new Uint8List(len);
    for (i = 0; i < len; i++) {
      a[i] = s.codeUnitAt(i);
    }
    socket.write(a.buffer);
  }

}


final statusCodeList = const {
  100: "Continue",
  101: "Switching Protocols",
  200: "OK",
  201: "Created",
  202: "Accepted",
  203: "Non-Authoritative Information",
  204: "No Content",
  205: "Reset Content",
  206: "Partial Content",
  300: "Multiple Choices",
  301: "Moved Permanently",
  302: "Found",
  303: "See Other",
  304: "Not Modified",
  305: "Use Proxy",
  306: "(Unused)",
  307: "Temporary Redirect",
  400: "Bad Request",
  401: "Unauthorized",
  402: "Payment Required",
  403: "Forbidden",
  404: "Not Found",
  405: "Method Not Allowed",
  406: "Not Acceptable",
  407: "Proxy Authentication Required",
  408: "Request Timeout",
  409: "Conflict",
  410: "Gone",
  411: "Length Required",
  412: "Precondition Failed",
  413: "Request Entity Too Large",
  414: "Request-URI Too Long",
  415: "Unsupported Media Type",
  416: "Requested Range Not Satisfiable",
  417: "Expectation Failed",
  500: "Internal Server Error",
  501: "Not Implemented",
  502: "Bad Gateway",
  503: "Service Unavailable",
  504: "Gateway Timeout",
  505: "HTTP Version Not Supported"
};
