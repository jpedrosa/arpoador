import "dart:typed_data";
import "dart:fletch.ffi";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


main() {
  var dir = MoreSys.opendir("/home/dewd/t_/jungle");
  var foreign, n = MoreSys.readdir(dir);
  while (n > 0) {
    foreign = new ForeignMemory.fromAddress(n, 280);
    p("ino: ${foreign.getUint32(0)}");
    p("type: ${foreign.getUint8(10)}");
    var c, a = [], s;
    for (int i = 11; i < 280; i++) {
      c = foreign.getUint8(i);
      if (c == 0) {
        break;
      } else {
        a.add(c);
      }
    }
    s = new String.fromCharCodes(a);
    p("name: ${s}");
    n = MoreSys.readdir(dir);
  }
  /*p("---------");
  for (int i = 0; i < 40; i++) {
    p(foreign.getUint8(i));
  }
  p("---------");
  for (int i = 0; i < 40; i++) {
    p(foreign.getUint16(i));
    //p(foreign.getUint16(i));
  }*/
  MoreSys.closedir(dir);
}
