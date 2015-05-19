library moresys;

import "dart:ffi";
import "dart:io";
import "dart:typed_data";
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

  static const DEFAULT_FILE_MODE = S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP |
      S_IROTH;

  static const int O_RDONLY  = 0;
  static const int O_RDWR    = 2;
  static const int O_CREAT   = 64; // 0100
  static const int O_TRUNC   = 512; // 01000
  static const int O_APPEND  = 1024; // 02000
  static const int O_DIRECTORY = 65536; // 0200000
  static const int O_CLOEXEC = 524288;

  static const int SEEK_SET = 0;
  static const int SEEK_CUR = 1;
  static const int SEEK_END = 2;

  static final _mkdir = Foreign.lookup("mkdir");
  static final _open = Foreign.lookup("open64");
  static final _close = Foreign.lookup("close");
  static final _write = Foreign.lookup("write");
  static final _read = Foreign.lookup("read");
  static final _lseek = Foreign.lookup("lseek64");
  static final _memcpy = Foreign.lookup("memcpy");
  static final _opendir = Foreign.lookup("opendir");
  static final _readdir = Foreign.lookup("readdir");
  static final _closedir = Foreign.lookup("closedir");
  static final _popen = Foreign.lookup("popen");
  static final _fgets = Foreign.lookup("fgets");
  static final _pclose = Foreign.lookup("pclose");
  static final _memchr = Foreign.lookup("memchr");
  static final _rawmemchr = Foreign.lookup("rawmemchr");
  static final _getenv = Foreign.lookup("getenv");

  static mkdir(String dirPath, [int mode = DEFAULT_DIR_MODE]) {
    var cPath = new Foreign.fromString(dirPath);
    var i = _retry(() => _mkdir.icall$2(cPath, mode));
    cPath.free();
    if (i == -1) {
      throw "mkdir failed to create directory.";
    }
  }

  static int open(String path, int flags, [int mode]) {
    Foreign cPath = new Foreign.fromString(path);
    int fd;
    if (mode == null) {
      fd = _retry(() => _open.icall$2(cPath, flags));
    } else {
      fd = _retry(() => _open.icall$3(cPath, flags, mode));
    }
    cPath.free();
    return fd;
  }

  static int openFile(String filePath, [String operation = "r",
      int mode = DEFAULT_FILE_MODE]) {
    int flags;
    if (operation == 'r') {
      flags = O_RDONLY;
    } else if (operation == 'w') {
      flags = O_RDWR | O_CREAT | O_TRUNC;
    } else if (operation == 'a') {
      flags = O_RDWR | O_CREAT | O_APPEND;
    } else {
      throw "Unexpected operation when opening file.";
    }
    flags |= O_CLOEXEC;
    Foreign cPath = new Foreign.fromString(filePath);
    int fd = _retry(() => _open.icall$3(cPath, flags, mode));
    cPath.free();
    return fd;
  }

  static int close(int fd) {
    return _retry(() => _close.icall$1(fd));
  }

  static int write(int fd, var buffer, int offset, int length) {
    _rangeCheck(buffer, offset, length);
    var address = buffer.getForeign().value + offset;
    return _retry(() => _write.icall$3(fd, address, length));
  }

  static int writeString(int fd, String string) {
    Foreign cPath = new Foreign.fromString(string);
    var i = _retry(() => _write.icall$3(fd, cPath.value, cPath.length));
    cPath.free();
    return i;
  }

  static int read(int fd, var buffer, int offset, int length) {
    _rangeCheck(buffer, offset, length);
    var address = buffer.getForeign().value + offset;
    return _retry(() => _read.icall$3(fd, address, length));
  }

  static int lseek(int fd, int offset, int whence) {
    return _retry(() => _lseek.Lcall$wLw(fd, offset, whence));
  }

  static void memcpy(var dest,
              int destOffset,
              var src,
              int srcOffset,
              int length) {
    var destAddress = dest.getForeign().value + destOffset;
    var srcAddress = src.getForeign().value + srcOffset;
    _memcpy.icall$3(destAddress, srcAddress, length);
  }

  static void memcpyMemToList(int address, var src, int srcOffset,
      int length) {
    _memcpy.icall$3(address, src.value + srcOffset, length);
  }

  static void memcpyMemToMem(int destAddress, var srcAddress, int length) {
    _memcpy.icall$3(destAddress, srcAddress, length);
  }

  static int readdir(int dirp) {
    return _readdir.icall$1(dirp);
  }

  static int opendir(String dirPath) {
    Foreign cPath = new Foreign.fromString(dirPath);
    int dirp = _opendir.icall$1(cPath);
    cPath.free();
    return dirp;
  }

  static int closedir(int dirp) {
    return _retry(() => _closedir.icall$1(dirp));
  }

  static int popen(String command, [String operation = "r"]) {
    Foreign cCommand = new Foreign.fromString(command);
    Foreign cOperation = new Foreign.fromString(operation);
    int fp = _popen.icall$2(cCommand, cOperation);
    cCommand.free();
    cOperation.free();
    return fp;
  }

  static int fgets(var buffer, int length, int fp) {
    return _fgets.icall$3(buffer.getForeign().value, length, fp);
  }

  static int pclose(int fp) {
    return _pclose.icall$1(fp);
  }

  static int memchr(int address, int byte, int length) {
    return _memchr.icall$3(address, byte, length);
  }

  static int rawmemchr(int address, int byte) {
    return _rawmemchr.icall$2(address, byte);
  }

  static String getenv(String name) {
    Foreign cName = new Foreign.fromString(name);
    var s, i = _getenv.icall$1(cName);
    cName.free();
    if (i != 0) {
      var n = _rawmemchr.icall$2(i, 0),
        list = new Uint8List(n - i);
      _memcpy.icall$3(list.buffer.getForeign().value, i, n - i);
      s = new String.fromCharCodes(list);
    }
    return s;
  }

  // Navigate the pointer maze.
  static get environment {
    var h = {}, envAddress = Foreign.lookup("environ").value, j = 0, tf, sp,
      firstByteAddress, list = new Uint8List(1024),
      firstItemAddress = new Foreign.fromAddress(envAddress, 4).getUint32(0),
      equalCharAddress, valueAddress, stringEndAddress,
      keyLen, key, valueLen;
    while (true) {
      sp = new Foreign.fromAddress(firstItemAddress + j, 4).getUint32(0);
      if (sp == 0) {
        break;
      }
      tf = new Foreign.fromAddress(sp, 20);
      firstByteAddress = _memchr.icall$3(sp, tf.getUint8(0), 1);
      equalCharAddress = _rawmemchr.icall$2(sp, 61);
      valueAddress = equalCharAddress + 1;
      stringEndAddress = _rawmemchr.icall$2(valueAddress, 0);
      keyLen = equalCharAddress - firstByteAddress;
      if (keyLen > list.length) {
        list = new Uint8List(keyLen);
      }
      _memcpy.icall$3(list.buffer.getForeign().value, sp, keyLen);
      key = new String.fromCharCodes(list, 0, keyLen);
      valueLen = stringEndAddress - valueAddress;
      if (valueLen > list.length) {
        list = new Uint8List(valueLen);
      }
      _memcpy.icall$3(list.buffer.getForeign().value, valueAddress, valueLen);
      h[key] = new String.fromCharCodes(list, 0, valueLen);
      j += 4;
    }
    return h;
  }

  static void _rangeCheck(ByteBuffer buffer, int offset, int length) {
    if (buffer.lengthInBytes < offset + length) {
      throw new IndexError(length, buffer);
    }
  }

  static int _retry(Function f) {
    int value;
    while ((value = f()) == -1) {
      if (Foreign.errno != Errno.EINTR) break;
    }
    return value;
  }

}
