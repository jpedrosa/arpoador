import "dart:typed_data";
import "dart:ffi";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class FileBrowser {

  static const DIRECTORY = 4;
  static const FILE = 8;

  /// get ino => _foreign.getUint32(0);
  void browse(String dirPath, fn(String name, int type)) {
    var dirp = MoreSys.opendir(dirPath);
    if (dirp == -1) {
      throw "Failed to open directory.";
    }
    try {
      var foreign, list = new Uint8List(270),
        listAddress = list.buffer.getForeign().value,
        n = MoreSys.readdir(dirp);
      while (n > 0) {
        foreign = new Foreign.fromAddress(n, 280);
        for (int i = 11; i < 280; i++) {
          if (foreign.getUint8(i) == 0) {
            MoreSys.memcpyMemToList(listAddress, foreign, 11, i - 11);
            fn(new String.fromCharCodes(list, 0, i - 11), foreign.getUint8(10));
            break;
          }
        }
        n = MoreSys.readdir(dirp);
      }
    } finally {
      MoreSys.closedir(dirp);
    }
  }

  static void scanDir(String dirPath, fn(String name, int type)) {
    new FileBrowser()..browse(dirPath, fn);
  }

  static void recurseDir(String dirPath, fn(String name, int type,
      String dirPath)) {
    var lasti = dirPath.length - 1;
    if (lasti >= 0) {
      if (dirPath.codeUnitAt(lasti) == 47) { // /
        dirPath = dirPath.substring(0, lasti);
      }
      doRecurseDir(dirPath, fn);
    }
  }

  static void doRecurseDir(String dirPath, fn(String name, int type,
      String dirPath)) {
    scanDir(dirPath, (name, type) {
      if (name != ".." && name != ".") {
        fn(name, type, dirPath);
        if (type == FileBrowser.DIRECTORY) {
          doRecurseDir("${dirPath}/${name}", fn);
        }
      }
      });
  }

  static String translateType(int type) {
    return type == FILE ? "f" : (type == DIRECTORY ? "d" : "?");
  }

}
