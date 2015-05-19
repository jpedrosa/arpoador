import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


main() {
  p(MoreSys.environment);
  p(MoreSys.getenv("USER"));
  p(MoreSys.getenv("PATH"));
}
