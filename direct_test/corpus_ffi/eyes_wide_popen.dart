import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


main() {
  var fp = MoreSys.popen("ls");
  if (fp != 0) {
    var n, list = new Uint8List(80), b = list.buffer,
      address = b.getForeign().address;
    while (MoreSys.fgets(b, 80, fp) != 0) {
      n = MoreSys.memchr(address, 0, 80);
      if (n == 0) {
        n = 80;
      } else {
        n -= address;
      }
      p(new String.fromCharCodes(list, 0, n));
    }
    MoreSys.pclose(fp);
  }
  p("over.");
}
