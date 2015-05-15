import '../../lib/arpoador.dart';
import '../../lib/io/io.dart';
import '../../lib/lang.dart';


handleSocket(socket) {
  Momentum.handle(socket, (req, res) {
    res.writeHead(200, {"Content-Type": "text/html"});
    res.write("<h1>Step 1</h1>");
    res.write("<ul><li>Step 2</<li></ul>");
    res.write("<hr>");
    res.write("Step 3.");
    });
}

main() {
  Momentum.listen(handler: handleSocket);
}
