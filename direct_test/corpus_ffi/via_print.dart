import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";
import "../../lib/io/io.dart";
import "dart:io";


pad(i) {
  var s;
  if (i < 10) {
    s = "  ${i}";
  } else if (i < 100) {
    s = " ${i}";
  } else {
    s = i.toString();
  }
  return s;
}


main() {
  p("Hello \x1b[32mWorld\x1b[0m!");
  for (var i = 0; i < 100; i++) {
    stdout.write("Count (\x1b[32m${pad(i)}\x1b[0m) down!\r");
    sleep(100);
  }
  for (var i = 0; i < 100; i++) {
    MoreSys.print("fish.txt");
    MoreSys.fflush();
    stdout.write("||");
    sleep(1000);
  }
}
