import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


main() {
  var fd = MoreSys.openFile("fish.txt");
  p(MoreSys.lseek(fd, 0, MoreSys.SEEK_END));
}
