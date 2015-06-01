import "dart:io" as DIO;
import "dart:typed_data";
import "../../lib/lang.dart";
import "../../lib/io/io.dart";


main() {
  var socket = new DIO.Socket.connect("127.0.0.1", 5555),
    b, list = new Uint8List(5);
  socket.write(list.buffer);
  b = socket.readNext();
  p(["start up length 326", 326 == b.lengthInBytes]);
  socket.write(list.buffer);
  var queryResponseLength = 0, packetsCount = 0;
  while ((b = socket.readNext()) != null) {
    p("Query response packet size: ${b.lengthInBytes}");
    packetsCount++;
    queryResponseLength += b.lengthInBytes;
  }
  p(["Query response length 209247", 209247 == queryResponseLength]);
  p("Query response packets count: ${packetsCount}");
}
