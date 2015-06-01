import "dart:io" as DIO;
import "dart:typed_data";
import "../../lib/lang.dart";
import "../../lib/io/io.dart";


handleSocket(socket) {
  try {
    var b = socket.readNext();
    if (b != null) {
      socket.write(IO.readWholeBuffer("start_up_bytes"));
      while ((b = socket.readNext()) != null) {
        socket.write(IO.readWholeBuffer("query_response_bytes"));
        break;
      }
    }
  } finally {
    socket.close();
  }
}


main() {
  var server = new DIO.ServerSocket("127.0.0.1", 5555);
  while (true) {
    server.spawnAccept(handleSocket);
  }
}
