import "dart:ffi";
import "../../lib/lang.dart";


class MoreSys {

  static const S_IFSOCK = 49152; // 0140000
  static const S_IFLNK = 40960; // 0120000
  static const S_IFREG = 32768; // 0100000
  static const S_IFBLK = 24576; // 060000
  static const S_IFDIR = 16384; // 040000
  static const S_IFCHR = 8192; // 020000
  static const S_IFIFO = 4096; // 010000
  static const S_ISUID = 2048; // 04000
  static const S_ISGID = 1024; // 02000
  static const S_ISVTX = 512; // 01000
  static const S_IRWXU = 448; // 0700
  static const S_IRUSR = 256; // 0400
  static const S_IWUSR = 128; // 0200
  static const S_IXUSR = 64; // 0100
  static const S_IRWXG = 56; // 070
  static const S_IRGRP = 32; // 040
  static const S_IWGRP = 16; // 020
  static const S_IXGRP = 8; // 010
  static const S_IRWXO = 7; // 07
  static const S_IROTH = 4; // 04
  static const S_IWOTH = 2; // 02
  static const S_IXOTH = 1; // 01

  static const DEFAULT_DIR_MODE = S_IRWXU | S_IRWXG | S_IRWXO;

  static final _mkdir = Foreign.lookup("mkdir");

  static mkdir(dirPath, [mode = DEFAULT_DIR_MODE]) {
    var i = _mkdir.icall$2(new Foreign.fromString(dirPath), mode);
    if (i == -1) {
      throw "mkdir failed to create directory.";
    }
  }

}
