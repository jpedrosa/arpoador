import '../../lib/arpoador.dart';


handleSocket(socket) {
  Momentum.handle(socket, (req, res) {
    res.writeHead(200, {"Content-Type": "text/html"});
    res.end("Ye<b>llo</b>w!<p>&nbsp;</p>${req}");
    });
}

main() {
  Momentum.listen(handler: handleSocket);
}
