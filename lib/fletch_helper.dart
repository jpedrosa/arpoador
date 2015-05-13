library fletch_helper;

import 'dart:typed_data';
import "lang.dart";


class FletchHelper {

  static codeUnitsToUint8List(s) {
    var len = s.length, i, a = new Uint8List(len);
    for (i = 0; i < len; i++) {
      a[i] = s.codeUnitAt(i);
    }
    return a;
  }

  static bytesToUint8List(bytes) {
    var len = bytes.length, i, a = new Uint8List(len);
    for (i = 0; i < len; i++) {
      a[i] = bytes[i];
    }
    return a;
  }

}
