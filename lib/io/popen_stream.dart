library popen_stream;

import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class PopenStream {

  static readLines(String command, fn(String string),
      [final int lineLength = 80]) {
    var fp = MoreSys.popen(command);
    if (fp != 0) {
      var n, list = new Uint8List(lineLength), b = list.buffer,
        address = b.getForeign().value;
      while (MoreSys.fgets(b, lineLength, fp) != 0) {
        n = MoreSys.memchr(address, 0, lineLength);
        if (n == 0) {
          n = lineLength;
        } else {
          n -= address;
        }
        fn(new String.fromCharCodes(list, 0, n));
      }
      MoreSys.pclose(fp);
    }
  }

}
