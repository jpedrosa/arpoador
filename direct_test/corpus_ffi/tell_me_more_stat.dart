import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/io/file.dart";
import "../../lib/lang.dart";


main() {
  p(MoreSys.stat("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
  p(File.exists("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
}
