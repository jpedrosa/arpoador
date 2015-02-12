import 'dart:io';
import 'dart:typed_data';


respond(socket, buffer) {
  var body = "Some <b>sample</b> text.",
    header = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: ",
    s = "${header}${body.length}\n\n${body}";
  var len = s.length, i, a = new Uint8List(len);
  for (i = 0; i < len; i++) {
    a[i] = s.codeUnitAt(i);
  }
  socket.write(a.buffer);
}

handleServerSocket(socket) {
  var buffer;
  while (true) {
    buffer = socket.readNext();
    if (buffer == null) {
      break;
    }
    respond(socket, buffer);
    socket.close();
    break;
  }
}

main() {
  var port = 8777,
    server = new ServerSocket("127.0.0.1", port);
  print("Starting server on port $port.");
  while (true) {
    server.spawnAccept(handleServerSocket);
  }
}
