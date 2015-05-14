library File;

import "dart:io" as DIO;
import "../lang.dart";
import "../fletch_helper.dart";
//import "../text/str.dart";


class DIOFile {

  static open(filePath, [mode = 'r']) {
    return new DIO.File.open(filePath, mode: parseStringMode(mode));
  }

  static parseStringMode(s) {
    var r;
    if (s == 'r') {
      r = DIO.File.READ;
    } else if (s == 'w') {
      r = DIO.File.WRITE;
    } else if (s == 'a') {
      r = DIO.File.APPEND;
    } else {
      throw "Unexpected file mode: ${s}";
    }
    return r;
  }

}


class File {

  var _f;

  File(filePath, [mode = 'r']) {
    _f = DIOFile.open(filePath, mode);
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
      length = _f.length;
    }
    var a = _f.read(length);
    return new String.fromCharCodes(a.asUint8List());
  }

  readBytes([length = -1]) {
    if (length < 0) {
      length = _f.length;
    }
    return _f.read(length).asUint8List();
  }

  readLines() {
    var r = [], a = readBytes(_f.length), i, si = 0, len = a.length;
    for (i = 0; i < len; i++) {
      if (a[i] == 10) {
        r.add(new String.fromCharCodes(a, si, i + 1));
        si = i + 1;
      }
    }
    return r;
  }

  write(string) {
    _f.write(FletchHelper.codeUnitsToUint8List(string).buffer);
  }

  writeBytes(List<int> bytes) {
    _f.write(FletchHelper.bytesToUint8List(bytes).buffer);
  }

  flush() {
    _f.flush();
  }

  close() {
    _f.close();
  }

  get length => _f.length;

  get position => _f.position;

  set position(v) {
    _f.setPosition(v);
  }

  get path => _f.path;

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

  toString() {
    return "File(path: ${inspect(path)})";
  }

}
