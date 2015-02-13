
import "dart:io";
import 'dart:convert';


main() {

  var port = 8779;

  ServerSocket.bind('127.0.0.1', port).then((serverSocket) {

    print('Started server on port ${port}.');

    serverSocket.listen((socket) {
      socket.transform(UTF8.decoder).listen((_) {
        var body = "Some <b>sample</b> text.",
          header = "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: ",
          s = "${header}${body.length}\n\n${body}";

        socket.write(s);
        socket.close();
      });
    });
  });

}
