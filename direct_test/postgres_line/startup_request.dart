import "dart:io";
import "dart:typed_data";
import "../../lib/fletch_helper.dart";
import "../../lib/lang.dart";
import "../../lib/sys/moresys.dart";


class PostgresClient {

  var _socket, _connected = false, _stage, _list, _foreign;

  PostgresClient() {
    _list = new Uint8List(4);
    _foreign = _list.buffer.getForeign();
  }

  connect({String address: "", int port: 5432, String user: "",
      String password: "", String database: ""}) {
    try {
      _socket = new Socket.connect(address, port);
    } catch (e) {
      throw "Failed to connect to address ${inspect(address)} "
          "on port ${port}.";
    }
    try {
      _socket.write(prepareStartUpBuffer(user, database).buffer);
    } catch (e) {
      throw "Failed to send the startup message.";
    }
    startUp();
  }

  static final FIELD_MAP = const {
    "S": "Severity",
    "C": "Code",
    "M": "Message",
    "D": "Detail",
    "H": "Hint",
    "P": "Position",
    "p": "Internal position",
    "q": "Internal query",
    "W": "Where",
    "s": "Schema name",
    "t": "Table name",
    "c": "Column name",
    "d": "Data type name",
    "n": "Constraint name",
    "F": "File",
    "L": "Line",
    "R": "Routine",
  };

  parseFields(list) {
    var h = {}, len = list.length, i = 5, fieldDesc, key,
      listAddress = list.buffer.getForeign().value, strStart, strLen;
    while (i + 2 < len) {
      key = new String.fromCharCode(list[i]);
      strStart = listAddress + i + 1;
      strLen = MoreSys.memchr(strStart, 0, len) - strStart;
      if (strLen > 0) {
        fieldDesc = FIELD_MAP[key];
        if (fieldDesc == null) {
          fieldDesc = key;
        }
        h[fieldDesc] = new String.fromCharCodes(list, i + 1, i + strLen + 1);
      } else {
        throw "Could not parse the field value.";
      }
      i += strLen + 2;
    }
    if (i < len) {
      if (i + 1 == len && list[i] == 0) {
        // OK. End of fields. So just ignore it.
      } else {
        throw "Could not parse the response fields.";
      }
    }
    return h;
  }

  getUint32(list, offset) {
    _list[0] = list[offset + 3];
    _list[1] = list[offset + 2];
    _list[2] = list[offset + 1];
    _list[3] = list[offset + 0];
    return _foreign.getUint32(0);
  }

  parseParameterStatus(list, offset) {
    var len = list.length;
    p("YES!");
  }

  parseAuthentication(list) {
    var msgLen = getUint32(list, 1),
      detail = getUint32(list, 5);
    if (detail == 0 && msgLen == 8) {
      _connected = true;
      p(["Connected", _connected]);
      if (9 < list.length) {
        parseParameterStatus(list, 9);
      }
    } else {
      throw "Unsupported authentication method.";
    }
  }

  parseServerResponse(list) {
    var len = list.length;
    if (len > 0) {
      var c = list[0];
      if (c == 82) { // R for Authentication.
        if (len > 8) {
          parseAuthentication(list);
        } else {
          throw "The Authentication response was too short.";
        }
      } else if (c == 69) { // E for ErrorResponse.
        throw "ErrorResponse: ${inspect(parseFields(list))}";
      } else {
        throw "Unsupported for now.";
      }
    } else {
      throw "Received an empty server response.";
    }
  }

  startUp() {
    var b = _socket.readNext();
    if (b != null) {
      p(["xxx", b.asUint8List()]);
      p(new String.fromCharCodes(b.asUint8List()));
      parseServerResponse(b.asUint8List());
    }
    p("end.");
  }

  copyStringToBuffer(bufferList, bufferOffset, s) {
    for (var i = 0, len = s.length; i < len; i++) {
      bufferList[bufferOffset + i] = s.codeUnitAt(i);
    }
  }

  setBufferLength(a, len) {
    // Reorder the bytes to place them in network byte order.
    if (len <= 255) {
      a[3] = len;
    } else if (len <= 65535) {
      _foreign.setUint16(0, len);
      a[3] = _list[0];
      a[2] = _list[1];
    } else if (len <= 2147483647) {
      _foreign.setUint32(0, len);
      a[3] = _list[0];
      a[2] = _list[1];
      a[1] = _list[2];
      a[0] = _list[3];
    } else {
      throw "Failed to set the buffer length because it exceeded the "
          "limit of unsigned 32 bits: ${len}";
    }
  }

  copyUserToBuffer(a, offset, user) {
    a[offset] = 117;     // u
    a[offset + 1] = 115; // s
    a[offset + 2] = 101; // e
    a[offset + 3] = 114; // r
    offset += 5;
    var i, len = user.length;
    for (i = 0; i < len; i++) {
      a[offset + i] = user.codeUnitAt(i);
    }
    return offset + len + 1;
  }

  copyDatabaseToBuffer(a, offset, database) {
    a[offset] = 100;     // d
    a[offset + 1] = 97;  // a
    a[offset + 2] = 116; // t
    a[offset + 3] = 97;  // a
    a[offset + 4] = 98;  // b
    a[offset + 5] = 97;  // a
    a[offset + 6] = 115; // s
    a[offset + 7] = 101; // e
    offset += 9;
    var i, len = database.length;
    for (i = 0; i < len; i++) {
      a[offset + i] = database.codeUnitAt(i);
    }
    return offset + len + 1;
  }

  prepareStartUpBuffer(user, database) {
    /*final header = [0, 0, 0, 0, // message length
        0, 3, 0, 0]; // protocol version*/
    var msgLen = 9, // space for length, protocol version and null terminator.
      gotUser = user.length > 0, gotDb = database.length > 0;
    if (gotUser) {
      // 6 is for the 4 "user" bytes and 2 null values marking their ends.
      msgLen += user.length + 6; // "user" 0 user 0
    }
    if (gotDb) {
      // 10 is for the 8 "database" bytes and 2 null values marking their ends.
      msgLen += database.length + 10; // "database" 0 database 0
    }
    var list = new Uint8List(msgLen), offset = 8;
    setBufferLength(list, msgLen);
    list[5] = 3; // protocol version
    if (gotUser) {
      offset = copyUserToBuffer(list, 8, user);
    }
    if (gotDb) {
      copyDatabaseToBuffer(list, offset, database);
    }
    p(list);
    return list;
  }

}


genLargeDatabaseName(len) {
  var i, sb = new StringBuffer();
  for (i = 0; i < len; i++) {
    sb.write("a");
  }
  return sb.toString();
}


main() {
  var pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  //pc.connect(database: genLargeDatabaseName(65535 + 10));
  //pc.connect(database: genLargeDatabaseName(300));
  p("ok");
}
