import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


main() {
  p(MoreSys.getpid());
  p(MoreSys.getcwd());
}
