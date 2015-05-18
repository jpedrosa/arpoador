import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/io/popen_stream.dart";
import "../../lib/io/io.dart";
import "../../lib/lang.dart";


main() {
  PopenStream.readLines("ls", (s) {
    p(s);
  });
  IO.popenReadLines("ls -la", p);
  p("c'est fini.");
}
