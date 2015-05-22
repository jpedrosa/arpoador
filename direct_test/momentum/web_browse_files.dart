import '../../lib/arpoador.dart';
import '../../lib/io/io.dart';
import '../../lib/io/getdents_file_browser.dart';
import '../../lib/lang.dart';


listDirectoryFiles(dirPath) {
  var sb = new StringBuffer();
  GetdentsFileBrowser.scanDir(dirPath, (name, type) {
    if (type == GetdentsFileBrowser.DIRECTORY) {
      sb.write('<a href="${name}">${name}</a><br />\n');
    } else {
      sb.write('${name}<br />\n');
    }
  });
  return sb.toString();
}


handleSocket(socket) {
  Momentum.handle(socket, (req, res) {
    res.writeHead(200, {"Content-Type": "text/html"});
    res.write(listDirectoryFiles("/home/dewd/t_/jungle"));
    });
}

main() {
  Momentum.listen(handler: handleSocket);
}
