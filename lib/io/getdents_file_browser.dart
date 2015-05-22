import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class GetdentsFileBrowser {

  static const DIRECTORY = 4;
  static const FILE = 8;

  static void scanDir(String dirPath, fn(name, type)) {
    var fd = MoreSys.doOpenDir(dirPath);
    if (fd != -1) {
      try {
        var len, i, reclen, list = new Uint8List(2048),
          foreign = list.buffer.getForeign(), address = foreign.value;
        do {
          len = MoreSys.getdents(fd, address, 2048);
          if (len <= 0) {
            break;
          }
          i = 0;
          while (i < len) {
            /*p(["ino", foreign.getUint32(i + 0)]);
            p(["offset", foreign.getUint32(i + 4)]);
            p(["reclen", foreign.getUint16(i + 8)]);
            reclen = foreign.getUint16(i + 8);
            p(["type", foreign.getUint8(i + reclen - 1)]);
            p(["name", new String.fromCharCodes(list, i + 10,
                MoreSys.memchr(address + i + 10, 0, reclen) - address)]);*/
            reclen = foreign.getUint16(i + 8);
            fn(new String.fromCharCodes(list, i + 10,
                MoreSys.memchr(address + i + 10, 0, reclen) - address),
                foreign.getUint8(i + reclen - 1));
            i += reclen;
          }
        } while (true);
      } finally {
        MoreSys.close(fd);
      }
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
          if (type == DIRECTORY) {
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
