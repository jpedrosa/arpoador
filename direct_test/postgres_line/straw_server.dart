import "dart:io" as DIO;
import "dart:typed_data";
import "../../lib/lang.dart";
import "../../lib/io/io.dart";
import "../../lib/sys/moresys.dart";


final PACKET_SIZE = 8192;

writePackets(socket, buffer) {
  var len = buffer.lengthInBytes,
    list = new Uint8List(PACKET_SIZE),
    listBuffer = list.buffer,
    listAddress = listBuffer.getForeign().value,
    bufferAddress = buffer.getForeign().value,
    offset = 0, size = PACKET_SIZE;
  while (offset < len) {
    if (offset + PACKET_SIZE >= len) {
      size = len - offset;
      list = new Uint8List(size);
      listBuffer = list.buffer;
      listAddress = listBuffer.getForeign().value;
    }
    MoreSys.memcpyMemToMem(listAddress, bufferAddress + offset, size);
    socket.write(listBuffer);
    DIO.sleep(10);
    offset += size;
  }
}

handleSocket(socket) {
  try {
    var b = socket.readNext();
    if (b != null) {
      socket.write(IO.readWholeBuffer("start_up_bytes"));
      while ((b = socket.readNext()) != null) {
        //socket.write(IO.readWholeBuffer("query_response_bytes"));
        writePackets(socket, IO.readWholeBuffer("query_response_bytes"));
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
