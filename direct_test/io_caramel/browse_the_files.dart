import "dart:typed_data";
import "dart:ffi";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class FileBrowser {

  var _foreign;

  static const DIRECTORY = 4;
  static const FILE = 8;

  void browse(String dirPath, fn(String name, int type)) {
    var dirp = MoreSys.opendir(dirPath);
    if (dirp == -1) {
      throw "Failed to open directory.";
    }
    try {
      var n = MoreSys.readdir(dirp);
      while (n > 0) {
        _foreign = new Foreign.fromAddress(n, 280);
        var c, a = [];
        for (int i = 11; i < 280; i++) {
          c = _foreign.getUint8(i);
          if (c == 0) {
            fn(new String.fromCharCodes(a), _foreign.getUint8(10));
            break;
          } else {
            a.add(c);
          }
        }
        n = MoreSys.readdir(dirp);
      }
    } finally {
      MoreSys.closedir(dirp);
    }
  }

  get ino => _foreign.getUint32(0);

  static void scanDir(String dirPath, fn(String name, int type)) {
    new FileBrowser()..browse(dirPath, fn);
  }

  static String translateType(int type) {
    return type == FILE ? "f" : (type == DIRECTORY ? "d" : "?");
  }

}


main() {
  FileBrowser.scanDir("/home/dewd/t_/jungle", (name, type) {
    p("${FileBrowser.translateType(type)}: ${name}");
  });
}
