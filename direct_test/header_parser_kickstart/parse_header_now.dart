import "../../lib/header_parser.dart";
import "../../lib/lang.dart";


genSample1() {
var s = """
GET /yes HTTP/1.1
Host: 127.0.0.1:8777
Connection: keep-alive
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/41.0.2272.76 Chrome/41.0.2272.76 Safari/537.36
Accept-Encoding: gzip, deflate, sdch
Accept-Language: en-US,en;q=0.8,pt-BR;q=0.6,pt;q=0.4
Cookie: GUID=QQ4Kwq0VRYGIJNsEduoX; sessions=%7B%7D
""";
return [71, 69, 84, 32, 47, 121, 101, 115, 32, 72, 84, 84, 80, 47, 49, 46, 49,
  13, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56,
  55, 55, 55, 13, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32,
  107, 101, 101, 112, 45, 97, 108, 105, 118, 101, 13, 10, 65, 99, 99, 101,
  112, 116, 58, 32, 116, 101, 120, 116, 47, 104, 116, 109, 108, 44, 97, 112,
  112, 108, 105, 99, 97, 116, 105, 111, 110, 47, 120, 104, 116, 109, 108, 43,
  120, 109, 108, 44, 97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47,
  120, 109, 108, 59, 113, 61, 48, 46, 57, 44, 105, 109, 97, 103, 101, 47,
  119, 101, 98, 112, 44, 42, 47, 42, 59, 113, 61, 48, 46, 56, 13, 10, 85,
  115, 101, 114, 45, 65, 103, 101, 110, 116, 58, 32, 77, 111, 122, 105,
  108, 108, 97, 47, 53, 46, 48, 32, 40, 88, 49, 49, 59, 32, 76, 105, 110,
  117, 120, 32, 120, 56, 54, 95, 54, 52, 41, 32, 65, 112, 112, 108, 101,
  87, 101, 98, 75, 105, 116, 47, 53, 51, 55, 46, 51, 54, 32, 40, 75, 72, 84,
  77, 76, 44, 32, 108, 105, 107, 101, 32, 71, 101, 99, 107, 111, 41, 32, 85,
  98, 117, 110, 116, 117, 32, 67, 104, 114, 111, 109, 105, 117, 109, 47, 52,
  49, 46, 48, 46, 50, 50, 55, 50, 46, 55, 54, 32, 67, 104, 114, 111, 109, 101,
  47, 52, 49, 46, 48, 46, 50, 50, 55, 50, 46, 55, 54, 32, 83, 97, 102, 97, 114,
  105, 47, 53, 51, 55, 46, 51, 54, 13, 10, 65, 99, 99, 101, 112, 116, 45, 69,
  110, 99, 111, 100, 105, 110, 103, 58, 32, 103, 122, 105, 112, 44, 32, 100,
  101, 102, 108, 97, 116, 101, 44, 32, 115, 100, 99, 104, 13, 10, 65, 99, 99,
  101, 112, 116, 45, 76, 97, 110, 103, 117, 97, 103, 101, 58, 32, 101, 110, 45,
  85, 83, 44, 101, 110, 59, 113, 61, 48, 46, 56, 44, 112, 116, 45, 66, 82, 59,
  113, 61, 48, 46, 54, 44, 112, 116, 59, 113, 61, 48, 46, 52, 13, 10, 67, 111,
  111, 107, 105, 101, 58, 32, 71, 85, 73, 68, 61, 81, 81, 52, 75, 119, 113, 48,
  86, 82, 89, 71, 73, 74, 78, 115, 69, 100, 117, 111, 88, 59, 32, 115, 101,
  115, 115, 105, 111, 110, 115, 61, 37, 55, 66, 37, 55, 68, 13, 10, 13, 10];
}


genSample10() {
var s = """
GET /yes HTTP/1.1
""";
return [71, 69, 84, 32, 47, 121, 101, 115, 32, 72, 84, 84, 80, 47, 49, 46, 49,
  13, 10];
}


genSample20() {
var s = """
GET /yes HTTP/1.1
Host: 127.0.0.1:8777
""";
return [71, 69, 84, 32, 47, 121, 101, 115, 32, 72, 84, 84, 80, 47, 49, 46, 49,
  13, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56,
  55, 55, 55, 13, 10];
}


genSample30() {
var s = """
GET /yes HTTP/1.1
Host: 127.0.0.1:8777
Connection: keep-alive
""";
return [71, 69, 84, 32, 47, 121, 101, 115, 32, 72, 84, 84, 80, 47, 49, 46, 49,
  13, 10, 72, 111, 115, 116, 58, 32, 49, 50, 55, 46, 48, 46, 48, 46, 49, 58, 56,
  55, 55, 55, 13, 10, 67, 111, 110, 110, 101, 99, 116, 105, 111, 110, 58, 32,
  107, 101, 101, 112, 45, 97, 108, 105, 118, 101, 13, 10];
}


main() {
  p("hey");
  var parser = new HeaderParser();
  parser.parse(genSample1());
  p(["header", parser.header]);
}
