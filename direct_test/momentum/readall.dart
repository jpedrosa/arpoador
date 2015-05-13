
import "dart:io";
import 'dart:typed_data';
import "../../lib/lang.dart";


main() {
  var f = new File.open("sample_file.html"), a;
  try {
    a = f.read(f.length);
  } finally {
    f.close();
  }
  var b = a.asUint8List();
  var s = new String.fromCharCodes(b);
  p(a.lengthInBytes);
  p(s);
}
