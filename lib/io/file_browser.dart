import "dart:typed_data";
import "dart:ffi";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class FileBrowser {

  static const DIRECTORY = 4;
  static const FILE = 8;

  /// get ino => _foreign.getUint32(0);
  static void scanDir(String dirPath, fn(String name, int type)) {
    var dirp = MoreSys.opendir(dirPath);
    if (dirp == 0) {
      throw "Failed to open directory.";
    }
    try {
      var foreign, list = new Uint8List(270), nameAddress,
        listAddress = list.buffer.getForeign().value,
        n = MoreSys.readdir(dirp), se;
      while (n > 0) {
        foreign = new Foreign.fromAddress(n, 280);
        nameAddress = foreign.value + 11;
        se = MoreSys.memchr(nameAddress, 0, 270);
        if (se > 0) {
          MoreSys.memcpyMemToMem(listAddress, nameAddress, se - nameAddress);
          fn(new String.fromCharCodes(list, 0, se - nameAddress),
              foreign.getUint8(10));
        }
        n = MoreSys.readdir(dirp);
      }
    } finally {
      MoreSys.closedir(dirp);
    }
  }

  static void recurseDir(String dirPath, fn(String name, int type,
      String dirPath)) {
    var lasti = dirPath.length - 1;
    if (lasti >= 0) {
      if (dirPath.codeUnitAt(lasti) == 47 && lasti > 0) { // /
        dirPath = dirPath.substring(0, lasti);
      }
      doRecurseDir(dirPath, fn);
    }
  }

  static void doRecurseDir(String dirPath, fn(String name, int type,
      String dirPath)) {
    try {
      scanDir(dirPath, (name, type) {
        if (name != ".." && name != ".") {
          fn(name, type, dirPath);
          if (type == FileBrowser.DIRECTORY) {
            doRecurseDir("${dirPath}/${name}", fn);
          }
        }
        });
    } catch (e) {
      // Silence errors in case of directories that cannot be opened.
    }
  }

  static String translateType(int type) {
    return type == FILE ? "f" : (type == DIRECTORY ? "d" : "?");
  }

}
