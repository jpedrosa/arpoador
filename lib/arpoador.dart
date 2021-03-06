library arpoador;

import 'dart:fletch.io';
import 'dart:typed_data';
import "lang.dart";
import "header_parser.dart";
import "fletch_helper.dart";
import "io/stat_buffer.dart";
import "io/io.dart";


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
    var request = new Request(socket);
    if (request.ready) {
      var response = new Response(socket);
      fn(request, response);
      response.doFlush();
    }
    socket.close();
  }

}


class Request {

  var _header;

  Request(socket) {
    var headerParser = new HeaderParser();
    var buffer;
    do {
      buffer = socket.readNext();
      if (buffer != null) {
        try {
          headerParser.parse(buffer.asUint8List());
          _header = headerParser.header;
        } catch (e) {
          break;
        }
      }
    } while (buffer != null && !headerParser.done);
  }

  get method => _header.method;

  get uri => _header.uri;

  get httpVersion => _header.httpVersion;

  get headerMap => _header.headerMap;

  operator [](k) => _header[k];

  get ready => _header != null;

  toString() {
    return 'Request(method: ${inspect(method)}, '
      'uri: ${inspect(uri)}, '
      'httpVersion: ${inspect(httpVersion)}, '
      'headerMap: ${inspect(headerMap)})';
  }

}


class Response {

  var socket, statusCode = 200, headerMap = const {"Content-Type": "text/html"},
    _contentQueue, _contentLength = 0;

  Response(this.socket) {
    _contentQueue = [];
  }

  writeHead(statusCode, headerMap) {
    this.statusCode = statusCode;
    this.headerMap = headerMap;
  }

  write(String string) {
    var a = FletchHelper.stringToUint8List(string);
    _contentQueue.add(a.buffer);
    _contentLength += a.buffer.lengthInBytes;
  }

  end(String string) {
    write(string);
  }

  writeBuffer(ByteBuffer buffer) {
    _contentLength += buffer.lengthInBytes;
    _contentQueue.add(buffer);
  }

  sendFile(filePath) {
    writeBuffer(IO.readWholeBuffer(filePath));
  }

  concatHeaderMap() {
    var s = "", kk = headerMap.keys, k;
    for (k in kk) {
      s += "${k}: ${headerMap[k]}\r\n";
    }
    return s;
  }

  doFlush() {
    var s = "HTTP/1.1 ${statusCode} ${statusCodeList[statusCode]}"
      "\r\n${concatHeaderMap()}Content-Length: ${_contentLength}\r\n\r\n";
    socket.write(FletchHelper.stringToUint8List(s).buffer);
    var a = _contentQueue, len = a.length, i;
    for (i = 0; i < len; i++) {
      socket.write(a[i]);
    }
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
