library io;

import "dart:typed_data";
import "file.dart";
import "popen_stream.dart";
import "stdout.dart";


class IO {

  static String read(String filePath) {
    var s;
    File.open(filePath, 'r', (f) => s = f.read());
    return s;
  }

  static List<String> readLines(String filePath) {
    var a;
    File.open(filePath, 'r', (f) => a = f.readLines());
    return a;
  }

  static List<int> readBytes(String filePath) {
    var a;
    File.open(filePath, 'r', (f) => a = f.readBytes());
    return a;
  }

  static ByteBuffer readWholeBuffer(String filePath) {
    var b;
    File.open(filePath, 'r', (f) => b = f.readWholeBuffer());
    return b;
  }

  static void write(String filePath, String string) {
    File.open(filePath, 'w', (f) => f.write(string));
  }

  static void writeBytes(String filePath, List<int> bytes) {
    File.open(filePath, 'w', (f) => f.writeBytes(bytes));
  }

  static void writeBuffer(String filePath, ByteBuffer buffer) {
    File.open(filePath, 'w', (f) => f.writeBuffer(buffer));
  }

  static void popenReadLines(var command, fn(String string),
      [int lineLength = 80]) {
    PopenStream.readLines(command, fn, lineLength);
  }

}


final stdout = new Stdout();
