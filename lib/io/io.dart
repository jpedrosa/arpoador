library io;

import "file.dart";
import "popen_stream.dart";
import "stdout.dart";


class IO {

  static read(filePath) {
    var s;
    File.open(filePath, 'r', (f) => s = f.read());
    return s;
  }

  static readLines(filePath) {
    var a;
    File.open(filePath, 'r', (f) => a = f.readLines());
    return a;
  }

  static readBytes(filePath) {
    var a;
    File.open(filePath, 'r', (f) => a = f.readBytes());
    return a;
  }

  static readWholeBuffer(filePath) {
    var b;
    File.open(filePath, 'r', (f) => b = f.readWholeBuffer());
    return b;
  }

  static write(filePath, string) {
    File.open(filePath, 'w', (f) => f.write(string));
  }

  static writeBytes(filePath, List<int> bytes) {
    File.open(filePath, 'w', (f) => f.writeBytes(bytes));
  }

  static void popenReadLines(command, fn(String string), [lineLength = 80]) {
    PopenStream.readLines(command, fn, lineLength);
  }

}


final stdout = const Stdout();
