import "../../lib/io/file.dart";
import "../../lib/lang.dart";


main() {
  p("ok");
  var f = new File("harvest.txt");
  p(["All that length", f.length]);
  p(f);
  p(f.read(3));
  p(f.read(3));
  p(f.readBytes(3));
  p(f.readLines());
  File.open("mission.txt", 'w', (f) => f.write("yo\nlo"));
}
