import "dart:typed_data";
import "../../lib/io/getdents_file_browser.dart";
import "../../lib/lang.dart";


main() {
  GetdentsFileBrowser.scanDir("/home/dewd/t_/jungle", (name, type) {
    p([name, type]);
  });
  GetdentsFileBrowser.recurseDir("/home/dewd/t_", (name, type, dirPath) {
    if (type == GetdentsFileBrowser.DIRECTORY) {
      p("${GetdentsFileBrowser.translateType(type)}: ${dirPath}${name}/");
    }
  });
}
