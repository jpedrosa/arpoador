import "../../lib/io/file_browser.dart";
import "../../lib/lang.dart";


main() {
  FileBrowser.scanDir("/home/dewd/t_/jungle", (name, type) {
    p("${FileBrowser.translateType(type)}: ${name}");
  });
  FileBrowser.recurseDir("/home/dewd/t_/", (name, type, dirPath) {
    if (type == FileBrowser.DIRECTORY) {
      p("${FileBrowser.translateType(type)}: ${dirPath}/${name}");
    }
  });
}
