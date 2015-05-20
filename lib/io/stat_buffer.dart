library stat_buffer;

import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/lang.dart";


class StatBuffer {

  var _bufferForeign;

  StatBuffer() {
    var list = new Uint8List(180);
    _bufferForeign = list.buffer.getForeign();
  }

  stat(path) {
    return MoreSys.stat(path, _bufferForeign.value) == 0;
  }

  lstat(path) {
    return MoreSys.lstat(path, _bufferForeign.value) == 0;
  }

  get dev => _bufferForeign.getUint32(0);

  get ino => _bufferForeign.getUint32(4);

  get mode => _bufferForeign.getUint16(8);

  get nlink => _bufferForeign.getUint16(10);

  get uid => _bufferForeign.getUint16(12);

  get gid => _bufferForeign.getUint16(14);

  get rdev => _bufferForeign.getUint32(16);

  get size => _bufferForeign.getUint32(20);

  get blksize => _bufferForeign.getUint32(24);

  get blocks => _bufferForeign.getUint32(28);

  // atime_nsec starts at 36.
  get atime => _bufferForeign.getUint32(32);

  // mtime_nsec starts at 44.
  get mtime => _bufferForeign.getUint32(40);

  // ctime_nsec starts at 52.
  get ctime => _bufferForeign.getUint32(48);

  toString() {
    return "StatBuffer(dev: ${dev}, ino: ${ino}, mode: ${mode}, "
        "nlink: ${nlink}, uid: ${uid}, gid: ${gid}, rdev: ${rdev}, "
        "size: ${size}, blksize: ${blksize}, blocks: ${blocks}, "
        "atime: ${atime}, mtime: ${mtime}, ctime: ${ctime})";
  }

}
