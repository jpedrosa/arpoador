library stat_buffer;

import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class StatBuffer {

  var _bufferForeign;
  StatMode _statMode;

  StatBuffer() {
    var list = new Uint8List(180);
    _bufferForeign = list.buffer.getForeign();
  }

  bool stat(String path) {
    return MoreSys.stat(path, _bufferForeign.value) == 0;
  }

  bool lstat(String path) {
    return MoreSys.lstat(path, _bufferForeign.value) == 0;
  }

  int get dev => _bufferForeign.getUint32(0);

  int get ino => _bufferForeign.getUint32(4);

  int get mode => _bufferForeign.getUint16(8);

  int get nlink => _bufferForeign.getUint16(10);

  int get uid => _bufferForeign.getUint16(12);

  int get gid => _bufferForeign.getUint16(14);

  int get rdev => _bufferForeign.getUint32(16);

  int get size => _bufferForeign.getUint32(20);

  int get blksize => _bufferForeign.getUint32(24);

  int get blocks => _bufferForeign.getUint32(28);

  // atime_nsec starts at 36.
  int get atime => _bufferForeign.getUint32(32);

  // mtime_nsec starts at 44.
  int get mtime => _bufferForeign.getUint32(40);

  // ctime_nsec starts at 52.
  int get ctime => _bufferForeign.getUint32(48);

  bool get isRegularFile => (mode & MoreSys.S_IFMT) == MoreSys.S_IFREG;

  bool get isDirectory => (mode & MoreSys.S_IFMT) == MoreSys.S_IFDIR;

  bool get isSymlink => (mode & MoreSys.S_IFMT) == MoreSys.S_IFLNK;

  get statMode {
    if (_statMode == null) {
      _statMode = new StatMode(mode);
    } else {
      _statMode.mode = mode;
    }
    return _statMode;
  }

  toString() {
    return "StatBuffer(dev: ${dev}, ino: ${ino}, mode: ${mode}, "
        "nlink: ${nlink}, uid: ${uid}, gid: ${gid}, rdev: ${rdev}, "
        "size: ${size}, blksize: ${blksize}, blocks: ${blocks}, "
        "atime: ${atime}, mtime: ${mtime}, ctime: ${ctime}, "
        "statMode: ${statMode})";
  }

}


class StatMode {

  int mode;

  StatMode([int this.mode = 0]);

  bool get isRegularFile => (mode & MoreSys.S_IFMT) == MoreSys.S_IFREG;

  bool get isDirectory => (mode & MoreSys.S_IFMT) == MoreSys.S_IFDIR;

  bool get isSymlink => (mode & MoreSys.S_IFMT) == MoreSys.S_IFLNK;

  bool get isSocket => (mode & MoreSys.S_IFMT) == MoreSys.S_IFSOCK;

  bool get isFifo => (mode & MoreSys.S_IFMT) == MoreSys.S_IFIFO;

  bool get isBlockDevice => (mode & MoreSys.S_IFMT) == MoreSys.S_IFBLK;

  bool get isCharacterDevice => (mode & MoreSys.S_IFMT) == MoreSys.S_IFCHR;

  String get modeTranslated {
    switch (mode & MoreSys.S_IFMT) {
      case MoreSys.S_IFREG: return "Regular File";
      case MoreSys.S_IFDIR: return "Directory";
      case MoreSys.S_IFLNK: return "Symlink";
      case MoreSys.S_IFSOCK: return "Socket";
      case MoreSys.S_IFIFO: return "FIFO/pipe";
      case MoreSys.S_IFBLK: return "Block Device";
      case MoreSys.S_IFCHR: return "Character Device";
      default: return "Unknown";
    }
  }

  String get octal {
    var a = [], i = mode, s;
    while (i > 7) {
      a.add(i.remainder(8));
      i = i ~/ 8;
    }
    s = i.toString();
    for (i = a.length - 1; i >= 0; i--) {
      s += a[i].toString();
    }
    return s;
  }

  String toString() {
    return "StatMode(modeTranslated: ${inspect(modeTranslated)}, "
        "octal: ${inspect(octal)})";
  }

}
