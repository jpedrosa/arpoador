import '../../lib/arpoador.dart';
import '../../lib/io/io.dart';
import '../../lib/lang.dart';


handleSocket(socket) {
  Momentum.handle(socket, (req, res) {
    res.writeHead(200, {"Content-Type": "text/html"});
    res.writeBuffer(IO.readWholeBuffer("sample_file.html"));
    });
}

main() {
  Momentum.listen(handler: handleSocket);
}
