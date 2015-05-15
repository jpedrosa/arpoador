import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


stringToUint8List(s) {
  var len = s.length, i, a = new Uint8List(len);
  for (i = 0; i < len; i++) {
    a[i] = s.codeUnitAt(i);
  }
  return a;
}


main() {
  MoreSys.openFile("fish.txt");
  var fd = MoreSys.openFile("solar.txt", "w");
  var b = stringToUint8List("Stained\nGlass.\n").buffer;
  MoreSys.write(fd, b, 0, b.lengthInBytes);
  MoreSys.writeString(fd, "Stained\nGlass.\n");
  MoreSys.writeString(fd, "Randomness\n");
  MoreSys.close(fd);
}
