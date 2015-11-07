library moresys;

import "dart:fletch.ffi";
import "package:os/os.dart";
import "dart:typed_data";
import "../../lib/lang.dart";


class MoreSys {

  static const S_IFMT = 61440; // 0170000
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

  static const int SYS_STAT = 106; // 4 on x64. 106 on x86.
  static const int SYS_LSTAT = 107; // 6 on x64. 107 on x86.
  static const int SYS_GETDENTS = 141; // 78 on x64. 141 on x86.
  static const int SYS_WRITE = 4; // 1 on x64. 4 on x86.

  static doLookup(functionName) => ForeignLibrary.main.lookup(functionName);

  static final _mkdir = doLookup("mkdir");
  static final _open = doLookup("open64");
  static final _close = doLookup("close");
  static final _write = doLookup("write");
  static final _read = doLookup("read");
  static final _lseek = doLookup("lseek64");
  static final _memcpy = doLookup("memcpy");
  static final _opendir = doLookup("opendir");
  static final _readdir = doLookup("readdir");
  static final _closedir = doLookup("closedir");
  static final _popen = doLookup("popen");
  static final _fgets = doLookup("fgets");
  static final _pclose = doLookup("pclose");
  static final _memchr = doLookup("memchr");
  static final _rawmemchr = doLookup("rawmemchr");
  static final _getenv = doLookup("getenv");
  static final _syscall = doLookup("syscall");
  static final _unlink = doLookup("unlink");
  static final _getpid = doLookup("getpid");
  static final _getcwd = doLookup("getcwd");
  static final _rename = doLookup("rename");
  static final _printf = doLookup("printf");
  static final _fflush = doLookup("fflush");

  static mkdir(String dirPath, [int mode = DEFAULT_DIR_MODE]) {
    var cPath = new ForeignMemory.fromStringAsUTF8(dirPath);
    var i = _retry(() => _mkdir.icall$2(cPath, mode));
    cPath.free();
    if (i == -1) {
      throw "mkdir failed to create directory.";
    }
  }

  static int open(String path, int flags, [int mode]) {
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(path);
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
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(filePath);
    int fd = _retry(() => _open.icall$3(cPath, flags, mode));
    cPath.free();
    return fd;
  }

  static int doOpenDir(String dirPath) {
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(dirPath);
    int fd = _retry(() => _open.icall$2(cPath, O_RDONLY | O_DIRECTORY));
    cPath.free();
    return fd;
  }

  static int close(int fd) {
    return _retry(() => _close.icall$1(fd));
  }

  static int write(int fd, var buffer, int offset, int length) {
    _rangeCheck(buffer, offset, length);
    var address = buffer.getForeign().address + offset;
    return _retry(() => _write.icall$3(fd, address, length));
  }

  static int writeString(int fd, String string) {
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(string);
    var i = _retry(() => _write.icall$3(fd, cPath.address, cPath.length));
    cPath.free();
    return i;
  }

  static int read(int fd, var buffer, int offset, int length) {
    _rangeCheck(buffer, offset, length);
    var address = buffer.getForeign().address + offset;
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
    var destAddress = dest.getForeign().address + destOffset;
    var srcAddress = src.getForeign().address + srcOffset;
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
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(dirPath);
    int dirp = _opendir.icall$1(cPath);
    cPath.free();
    return dirp;
  }

  static int closedir(int dirp) {
    return _retry(() => _closedir.icall$1(dirp));
  }

  static int popen(String command, [String operation = "r"]) {
    ForeignMemory cCommand = new ForeignMemory.fromStringAsUTF8(command);
    ForeignMemory cOperation = new ForeignMemory.fromStringAsUTF8(operation);
    int fp = _popen.icall$2(cCommand, cOperation);
    cCommand.free();
    cOperation.free();
    return fp;
  }

  static int fgets(var buffer, int length, int fp) {
    return _fgets.icall$3(buffer.getForeign().address, length, fp);
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
    ForeignMemory cName = new ForeignMemory.fromStringAsUTF8(name);
    var s, i = _getenv.icall$1(cName);
    cName.free();
    if (i != 0) {
      var n = _rawmemchr.icall$2(i, 0),
        list = new Uint8List(n - i);
      _memcpy.icall$3(list.buffer.getForeign().address, i, n - i);
      s = new String.fromCharCodes(list);
    }
    return s;
  }

  static get environment {
    // Navigate the pointer maze.
    var h = {}, envAddress = doLookup("environ").address, j = 0, tf, sp,
      firstByteAddress, list = new Uint8List(1024),
      listAddress = list.buffer.getForeign().address,
      firstItemAddress =
          new ForeignMemory.fromAddress(envAddress, 4).getUint32(0),
      equalCharAddress, valueAddress, stringEndAddress,
      keyLen, key, valueLen;
    while (true) {
      sp = new ForeignMemory.fromAddress(firstItemAddress + j, 4).getUint32(0);
      if (sp == 0) {
        break;
      }
      tf = new ForeignMemory.fromAddress(sp, 20);
      // Workaround. We take the first byte address to sort of normalize
      // the integer value or memory address value, otherwise during the
      // conversion from machine to Dart integer there could be some kind
      // nagging overflow that when compared with the next values to get
      // the length of key and value tokens would not represent the right
      // sizes.
      firstByteAddress = _memchr.icall$3(sp, tf.getUint8(0), 1);
      equalCharAddress = _rawmemchr.icall$2(sp, 61);
      valueAddress = equalCharAddress + 1;
      stringEndAddress = _rawmemchr.icall$2(valueAddress, 0);
      keyLen = equalCharAddress - firstByteAddress;
      if (keyLen > list.length) {
        list = new Uint8List(keyLen);
        listAddress = list.buffer.getForeign().address;
      }
      _memcpy.icall$3(listAddress, sp, keyLen);
      key = new String.fromCharCodes(list, 0, keyLen);
      valueLen = stringEndAddress - valueAddress;
      if (valueLen > list.length) {
        list = new Uint8List(valueLen);
        listAddress = list.buffer.getForeign().address;
      }
      _memcpy.icall$3(listAddress, valueAddress, valueLen);
      h[key] = new String.fromCharCodes(list, 0, valueLen);
      j += 4;
    }
    return h;
  }

  static int stat(String path, [int bufferAddress = 0]) {
    return doStat(SYS_STAT, path, bufferAddress);
  }

  static int lstat(String path, [int bufferAddress = 0]) {
    return doStat(SYS_LSTAT, path, bufferAddress);
  }

  static int doStat(int sysStat, String path, int bufferAddress) {
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(path);
    if (bufferAddress == 0) {
      // sizeof of the stat struct shows 144. We give it some room.
      var list = new Uint8List(180);
      bufferAddress = list.buffer.getForeign().address;
    }
    int i = _syscall.icall$3(sysStat, cPath, bufferAddress);
    cPath.free();
    return i;
  }

  static int unlink(String path) {
    ForeignMemory cPath = new ForeignMemory.fromStringAsUTF8(path);
    int i = _unlink.icall$1(cPath);
    cPath.free();
    return i;
  }

  static int getpid() {
    return _getpid.icall$0();
  }

  static String getcwd() {
    var list = new Uint8List(255), foreign = list.buffer.getForeign();
    var s, i = _getcwd.icall$2(foreign.address, 255);
    if (i != 0) {
      var n = _memchr.icall$3(i, 0, 255);
      s = new String.fromCharCodes(list, 0, n - i);
    }
    return s;
  }

  static int rename(String oldPath, String newPath) {
    ForeignMemory cOldPath = new ForeignMemory.fromStringAsUTF8(oldPath);
    ForeignMemory cNewPath = new ForeignMemory.fromStringAsUTF8(newPath);
    int i = _rename.icall$2(cOldPath, cNewPath);
    cOldPath.free();
    cNewPath.free();
    return i;
  }

  static int fflush([int stream = 0]) {
    return _fflush.icall$1(stream);
  }

  static int getdents(int fd, int bufferAddress, int bufferSize) {
    return _syscall.icall$4(SYS_GETDENTS, fd, bufferAddress, bufferSize);
  }

  static int print(String string) {
    ForeignMemory cString = new ForeignMemory.fromStringAsUTF8(string);
    var i = _syscall.icall$4(SYS_WRITE, 1, cString, cString.length);
    cString.free();
    return i;
  }

  static void _rangeCheck(ByteBuffer buffer, int offset, int length) {
    if (buffer.lengthInBytes < offset + length) {
      throw new IndexError(length, buffer);
    }
  }

  static int _retry(f()) {
    int value;
    while ((value = f()) == -1) {
      if (Foreign.errno != Errno.EINTR) break;
    }
    return value;
  }

}
