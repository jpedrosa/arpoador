import "../../lib/io/io.dart";
import "../../lib/lang.dart";
import "dart:io" as DIO;


main() {
  p("ok");
  p(IO.read("harvest.txt"));
  p(IO.readLines("harvest.txt"));
  p(IO.readBytes("harvest.txt"));
}
