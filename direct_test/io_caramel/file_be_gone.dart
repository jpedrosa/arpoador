import "../../lib/io/file.dart";
import "../../lib/lang.dart";


main() {
  File.rename("/home/dewd/t_/jungle/tmpjunk1.txt",
      "/home/dewd/t_/jungle/tmpjunk.txt");
  File.delete("/home/dewd/t_/jungle/tmpjunk.txt");
}
