import "dart:typed_data";
import "../../lib/sys/moresys.dart";
import "../../lib/io/file.dart";
import "../../lib/io/stat_buffer.dart";
import "../../lib/lang.dart";


main() {
  var sb = new StatBuffer(), sm = new StatMode();
  p(sb.stat("/home/dewd/t_/jungle/dirent_oh_dirent.c"));
  sm.mode = sb.mode;
  p(sm);
  p(sb.stat("/home/"));
  sm.mode = sb.mode;
  p(sm);
  p(sb.stat("/proc/meminfo"));
  p(sb);
  p(sb.stat("/dev/console"));
  p(sb);
}
