import "../../lib/lang.dart";
import "../../lib/io/io.dart";
import "../../lib/sys/moresys.dart";


main() {
  p(IO.readWholeBuffer("start_up_bytes").asUint8List());
  var list = IO.readWholeBuffer("query_response_bytes").asUint8List();
  //print(list.toString());
  var nullCount = 0, c, sb = new StringBuffer(), len = list.length;
  sb.write(len > 0 ? "[${list[0]}" : "[");
  for (var i = 1; i < len; i++) {
    c = list[i];
    if (list[i] == 0) {
      nullCount++;
    }
    sb.write(", ${c}");
  }
  sb.write("]");
  //MoreSys.print(list.length.toString());
  p(sb.toString());
  p(["nullCount", nullCount]);
}
