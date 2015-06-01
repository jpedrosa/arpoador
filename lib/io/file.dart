library File;

import "dart:typed_data";
import "../lang.dart";
import "../fletch_helper.dart";
import "../sys/moresys.dart";
//import "../text/str.dart";


class File {

  var _fd, _filePath;

  File(filePath, [mode = 'r']) {
    _fd = MoreSys.openFile(filePath, mode);
    if (_fd == -1) {
      throw "Failed to open file.";
    }
    _filePath = filePath;
  }

  static const NEW_LINE = "\n";
  static const WINDOWS_NEW_LINE = "\r\n";

  puts(v) {
    var f = _f;
    if (v is List) {
      var i, len = v.length;
      for (i = 0; i < len; i++) {
        putStringEnsureNewLine(f, v[i]);
      }
    } else if (v is Iterable) {
      for (var e in v) {
        putStringEnsureNewLine(f, e);
      }
    } else {
      write(v is String ? v : v.toString());
    }
  }

  putStringEnsureNewLine(f, s) {
    if (s is! String) {
      s = s.toString();
    }
    Str.withNewLinePreference(s, IO.isWindows, (s, newLineStr) {
      write(s);
      if (newLineStr != null) {
        write(newLineStr);
      }
      });
  }

  operator << (string) {
    write(string);
    return this;
  }

  print(v) {
    write(v is String ? v : v.toString());
  }

  read([length = -1]) {
    if (length < 0) {
      length = this.length;
    }
    var a = doRead(length);
    return new String.fromCharCodes(a.asUint8List());
  }

  readBytes([length = -1]) {
    if (length < 0) {
      length = this.length;
    }
    return doRead(length).asUint8List();
  }

  readLines() {
    var r = [], a = readBytes(this.length), i, si = 0, len = a.length;
    for (i = 0; i < len; i++) {
      if (a[i] == 10) {
        r.add(new String.fromCharCodes(a, si, i + 1));
        si = i + 1;
      }
    }
    return r;
  }

  readWholeBuffer() => doRead(length);

  write(string) {
    MoreSys.writeString(_fd, string);
  }

  writeBytes(List<int> bytes) {
    var b = FletchHelper.bytesToUint8List(bytes).buffer;
    MoreSys.write(_fd, b, 0, b.lengthInBytes);
  }

  writeBuffer(ByteBuffer buffer, [int offset = 0, int length = -1]) {
    if (length < 0) {
      length = buffer.lengthInBytes;
    }
    MoreSys.write(_fd, buffer, offset, length);
  }

  flush() {
    // Not implemented yet.
  }

  close() {
    if (_fd != -1) {
      MoreSys.close(_fd);
    }
    _fd = -1;
  }

  get isOpen => _fd != -1;

  /**
   * Read up to [maxBytes] from the file.
   */
  ByteBuffer doRead(int maxBytes) {
    Uint8List list = new Uint8List(maxBytes);
    ByteBuffer buffer = list.buffer;
    int result = MoreSys.read(_fd, buffer, 0, maxBytes);
    if (result == -1) _error("Failed to read from file");
    if (result < maxBytes) {
      Uint8List truncated = new Uint8List(result);
      ByteBuffer newBuffer = truncated.buffer;
      MoreSys.memcpy(newBuffer, 0, buffer, 0, result);
      buffer = newBuffer;
    }
    return buffer;
  }

  /**
   * Get the current position within the file.
   */
  int get position {
    int value = MoreSys.lseek(_fd, 0, MoreSys.SEEK_CUR);
    if (value == -1) _error("Failed to get the current file position");
    return value;
  }

  /**
   * Seek the position within the file.
   */
  void set position(int value) {
    if (MoreSys.lseek(_fd, value, MoreSys.SEEK_SET) != value) {
      _error("Failed to set file offset to '$value'");
    }
  }

  /**
   * Get the length of the file.
   */
  int get length {
    int current = position;
    int end = MoreSys.lseek(_fd, 0, MoreSys.SEEK_END);
    if (current == -1) _error("Failed to get file length");
    position = current;
    return end;
  }

  get path => _filePath;

  static open(filePath, [mode = 'r', fn(f)]) {
    var f = new File(filePath, mode);
    if (fn != null) {
      try {
        fn(f);
      } finally {
        f.close();
      }
    }
    return f;
  }

  static bool exists(String filePath) => MoreSys.stat(filePath) == 0;

  /**
   * Delete the file at [path] from disk.
   */
  static void delete(String path) {
    if (MoreSys.unlink(path) == -1) {
      throw new FileException("Failed to remove file");
    }
  }

  static void rename(String oldPath, String newPath) {
    if (MoreSys.rename(oldPath, newPath) == -1) {
      throw new FileException("Failed to rename the file.");
    }
  }

  void _error(String message) {
    close();
    throw new FileException(message);
  }

  toString() {
    return "File(path: ${inspect(path)})";
  }

}


class FileException implements Exception {
  final String message;

  FileException(this.message);

  String toString() => "FileException: $message";
}
