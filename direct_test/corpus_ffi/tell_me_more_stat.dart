import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/io/file.dart";
import "../../lib/lang.dart";


class StatBuffer {

  var _bufferForeign, _success = false;

  StatBuffer() {
    var list = new Uint8List(180);
    _bufferForeign = list.buffer.getForeign();
  }

  stat(path) {
    var i = MoreSys.stat(path, _bufferForeign.value);
    _success = i == 0;
    return _success;
  }

  get dev => _bufferForeign.getUint32(0);

  toString() {
    if (_success) {
      return "StatBuffer(dev: ${dev})";
    } else {
      return "StatBuffer()";
    }
  }

}

main() {
  p(MoreSys.stat("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
  p(File.exists("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
  var sb = new StatBuffer();
  p(sb.stat("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
  p(sb);
}
