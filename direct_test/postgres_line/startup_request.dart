import "dart:io";
import "dart:typed_data";
import "../../lib/fletch_helper.dart";
import "../../lib/lang.dart";
import "../../lib/sys/moresys.dart";


class FieldDescription {

  var name = "", tableObjectId = 0, columnAttributeNumber = 0,
    dataTypeObjectId = 0, dataTypeSize = 0, typeModifier = 0,
    formatCode = 0;

  toString() {
    return "FieldDescription(name: ${inspect(name)}, "
        "tableObjectId: ${tableObjectId}, "
        "columnAttributeNumber: ${columnAttributeNumber}, "
        "dataTypeObjectId: ${dataTypeObjectId}, "
        "dataTypeSize: ${dataTypeSize}, "
        "typeModifier: ${typeModifier}, "
        "formatCode: ${formatCode})";
  }

}


class QueryResults {

  var fields = [], rows = [];

  toString() {
    return "QueryResults(fields: ${inspect(fields)}, "
        "rows: ${rows})";
  }

}


class PostgresClient {

  var _socket, _connected = false, _list, _foreign, _parameters = const {},
    _processId = 0, _secretKey = 0, _backEndStatus = 0;

  PostgresClient() {
    _list = new Uint8List(4);
    _foreign = _list.buffer.getForeign();
  }

  /* Helper section */

  getUint32(list, offset) {
    _list[0] = list[offset + 3];
    _list[1] = list[offset + 2];
    _list[2] = list[offset + 1];
    _list[3] = list[offset + 0];
    return _foreign.getUint32(0);
  }

  getUint16(list, offset) {
    _list[0] = list[offset + 1];
    _list[1] = list[offset + 0];
    return _foreign.getUint16(0);
  }

  getInt32(list, offset) {
    _list[0] = list[offset + 3];
    _list[1] = list[offset + 2];
    _list[2] = list[offset + 1];
    _list[3] = list[offset + 0];
    return _foreign.getInt32(0);
  }

  /* End of Helper section */

  /* StartUp section */

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
    readStartUp();
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
    var h = {}, len = list.length, i = 5, fieldDesc, key, c,
      listAddress = list.buffer.getForeign().value, strStart, strLen;
    while (i + 2 < len) {
      c = list[i];
      if (c == 0) {
        break;
      }
      key = new String.fromCharCode(c);
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
      if ((i + 1 == len && list[i] == 0) || list[i] == 0) {
        // OK. End of fields. So just ignore it.
      } else {
        throw "Could not parse the response fields.";
      }
    }
    return h;
  }

  parseNameValuePair(list, offset, fn(name, value)) {
    var len = list.length, name, strStart, strLen, valueOffset,
      listAddress = list.buffer.getForeign().value;
    strStart = listAddress + offset;
    strLen = MoreSys.memchr(strStart, 0, len) - strStart;
    if (strLen > 0) {
      name = new String.fromCharCodes(list, offset, offset + strLen);
      valueOffset = offset + strLen + 1;
      if (valueOffset + 1 < len) {
        strStart = listAddress + valueOffset;
        strLen = MoreSys.memchr(strStart, 0, len) - strStart;
        if (strLen >= 0) {
          fn(name, new String.fromCharCodes(list, valueOffset,
              valueOffset + strLen));
        } else {
          throw "Could not parse the value.";
        }
      } else {
        throw "Could not parse the value.";
      }
    } else {
      throw "Could not parse the name.";
    }
    return valueOffset + strLen + 1;
  }

  parseParameterStatus(list, offset) {
    if (offset + 5 < list.length) {
      // No need to parse the message length. So just skip it.
      // var msgLen = getUint32(list, offset + 1);
      return parseNameValuePair(list, offset + 5, (name, value) {
        _parameters[name] = value;
      });
    } else {
      throw "Parameter status response was too short.";
    }
  }

  parseBackendKeyData(list, offset) {
    if (offset + 12 < list.length) {
      // Ignore the message length.
      // getUint32(list, offset + 1)
      _processId = getUint32(list, offset + 5);
      _secretKey = getUint32(list, offset + 9);
    } else {
      throw "The BackendKeyData response was too short.";
    }
    return offset + 13;
  }

  parseReadyForQuery(list, offset) {
    if (offset + 5 < list.length) {
      _backEndStatus = list[offset + 5];
    } else {
      throw "The BackendKeyData response was too short.";
    }
    return offset + 13;
  }

  parsePostAuthentication(list, offset) {
    var c, len = list.length;
    _parameters = {};
    while (offset < len) {
      c = list[offset];
      if (c == 83) { // S for ParameterStatus.
        offset = parseParameterStatus(list, offset);
      } else if (c == 75) { // K for BackendKeyData.
        offset = parseBackendKeyData(list, offset);
      } else if (c == 90) { // Z for ReadyForQuery.
        offset = parseReadyForQuery(list, offset);
      } else {
        p(["ccc", c]);
        throw "Unsupported for now.";
      }
    }
  }

  parseAuthentication(list) {
    var msgLen = getUint32(list, 1), detail = getUint32(list, 5);
    if (detail == 0 && msgLen == 8) {
      parsePostAuthentication(list, 9);
      _connected = true;
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

  readStartUp() {
    var b = _socket.readNext();
    if (b != null) {
      p(["xxx", b.asUint8List()]);
      parseServerResponse(b.asUint8List());
    }
    p("end.");
  }

  setBufferLength(a, offset, len) {
    // Reorder the bytes to place them in network byte order.
    if (len <= 255) {
      a[3 + offset] = len;
    } else if (len <= 65535) {
      _foreign.setUint16(0, len);
      a[3 + offset] = _list[0];
      a[2 + offset] = _list[1];
    } else if (len <= 2147483647) {
      _foreign.setUint32(0, len);
      a[3 + offset] = _list[0];
      a[2 + offset] = _list[1];
      a[1 + offset] = _list[2];
      a[0 + offset] = _list[3];
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
    setBufferLength(list, 0, msgLen);
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

  /* End of StartUp section */

  /* Query section */

  copyStringToBuffer(bufferList, offset, string) {
    for (var i = 0, len = string.length; i < len; i++) {
      bufferList[offset + i] = string.codeUnitAt(i);
    }
  }

  query(String command) {
    // 5 is for 32bits length, null after string.
    var msgLen = 5 + command.length, list = new Uint8List(msgLen + 1);
    list[0] = 81; // Q
    setBufferLength(list, 1, msgLen);
    copyStringToBuffer(list, 5, command);
    p(["query", list]);
    try {
      _socket.write(list.buffer);
    } catch (e) {
      throw "Failed to send the startup message.";
    }
    readQueryResults();
  }

  readQueryResults() {
    var b = _socket.readNext();
    if (b != null) {
      p(["query results", b.asUint8List()]);
      parseQueryResponse(b.asUint8List());
    }
  }

  findStringLength(address, len) {
    return MoreSys.memchr(address, 0, len) - address;
  }

  parseRowDescription(list, queryResults) {
    var len = list.length;
    if (len < 7) {
      throw "RowDescription response is too short.";
    }
    var ff = [], columnCount = getUint16(list, 5), fd,
      listAddress = list.buffer.getForeign().value, offset = 7, strLen;
    while (columnCount > 0) {
      fd = new FieldDescription();
      ff.add(fd);
      strLen = findStringLength(listAddress + offset, len);
      fd.name = new String.fromCharCodes(list, offset, offset + strLen);
      offset += strLen + 1;
      fd.tableObjectId = getUint32(list, offset);
      fd.columnAttributeNumber = getUint16(list, offset + 4);
      fd.dataTypeObjectId = getUint32(list, offset + 6);
      fd.dataTypeSize = getUint16(list, offset + 10);
      fd.typeModifier = getUint32(list, offset + 12);
      fd.formatCode = getUint16(list, offset + 16);
      columnCount--;
      offset += 18;
    }
    queryResults.fields = ff;
    return offset;
  }

  static final STRING_DATATYPE = 19;
  static final BOOLEAN_DATATYPE = 16;
  static final TEXT_BLOB_DATATYPE = 25; // max size: 65535

  parseDataRows(list, offset, queryResults) {
    var rows = [], fields = queryResults.fields;
    //var columnCount = getUint16(list, offset + 5);
    var columnCount = fields.length; // Take a shortcut.
    var ncol, dt, v, valueLen, row, len = list.length;
    do {
      offset += 7;
      row = [];
      for (ncol = 0; ncol < columnCount; ncol++) {
        dt = fields[ncol].dataTypeObjectId;
        valueLen = getInt32(list, offset);
        offset += 4;
        if (valueLen < 0) {
          if (valueLen == -1) {
            v = null;
            valueLen = 0;
          } else {
            throw "Unsupported negative value length.";
          }
        } else if (dt == STRING_DATATYPE || dt == TEXT_BLOB_DATATYPE) {
          v = new String.fromCharCodes(list, offset, offset + valueLen);
        } else if (dt == BOOLEAN_DATATYPE) {
          v = list[offset] == 116;
        } else {
          throw "Unsupported data type (${dt}) for now.";
        }
        row.add(v);
        offset += valueLen;
      }
      rows.add(row);
    } while (offset < len && list[offset] == 68); // D for another DataRow.
    queryResults.rows = rows;
  }

  parseQueryResponse(list) {
    var len = list.length;
    if (len == 0) {
      throw "The query response is empty.";
    }
    var c = list[0];
    if (c == 84) { // T for RowDescription.
      var qr = new QueryResults(), offset;
      offset = parseRowDescription(list, qr);
      if (offset < len) {
        if (list[offset] == 68) { // D
          parseDataRows(list, offset, qr);
        } else {
          throw "Unsupported for now.";
        }
      }
      p(["qr", qr]);
    } else if (c == 69) { // E for ErrorResponse.
      throw "ErrorResponse: ${inspect(parseFields(list))}";
    } else {
      throw "Unsupported for now.";
    }
  }

  /* End of Query section */

  static final BACKEND_STATUS_I = 73; // I - Idle
  static final BACKEND_STATUS_T = 84; // T - Transaction block
  static final BACKEND_STATUS_E = 69; // E - Failed transaction block

  get isConnected => _connected;

  get parameters => _parameters;

  get processId => _processId;

  get secretKey => _secretKey;

  get backEndStatus => _backEndStatus;

  get translatedBackEndStatus => _backEndStatus > 0 ?
      new String.fromCharCode(_backEndStatus) : null;

  toString() {
    return "PostgresClient(connected: ${_connected}, "
        "parameters: ${inspect(_parameters)}, "
        "processId: ${_processId}, secretKey: ${_secretKey}, "
        "translatedBackEndStatus: ${inspect(translatedBackEndStatus)})";
  }

}


genLargeDatabaseName(len) {
  var i, sb = new StringBuffer();
  for (i = 0; i < len; i++) {
    sb.write("a");
  }
  return sb.toString();
}

genSampleQuery1() {
  return "select tablename from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery10() {
  return "select * from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery20() {
  return "select schemaname, tablename from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery30() {
  return "select hasindexes from pg_tables "
      "where schemaname = 'pg_catalog' "
      "order by tablename";
}


genSampleQuery40() {
  return "select * from pg_statistic";
}


genSampleQuery50() {
  return "select * from pg_attribute";
}


genSampleQuery60() {
  return "select * from pg_attrdef";
}


genSampleQuery70() {
  return "select description from pg_description";
}




main() {
  var pc = new PostgresClient();
  pc.connect(address: "127.0.0.1", user: "postgres", database: "devel");
  //pc.connect(database: genLargeDatabaseName(65535 + 10));
  //pc.connect(database: genLargeDatabaseName(300));
  p(pc);
  pc.query(genSampleQuery1());
}
