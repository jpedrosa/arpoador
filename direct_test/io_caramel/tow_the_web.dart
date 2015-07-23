import "dart:fletch.io";
import "../../lib/fletch_helper.dart";
import "../../lib/io/file.dart";
import "../../lib/lang.dart";


main() {
  var socket = new Socket.connect("127.0.0.1", 8777),
    command = "GET /that/one HTTP1/1\r\n\r\n",
    list = FletchHelper.stringToUint8List(command);
  socket.write(list.buffer);
  var b = socket.readNext();
  if (b != null) {
    p(new String.fromCharCodes(b.asUint8List()));
  }
  p("ok");
}
