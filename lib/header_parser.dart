library header_parser;

import "lang.dart";


class Header {

  var method, uri, httpVersion, headerMap = {};

  operator [](k) => headerMap[k];

  operator []=(k, v) {
    headerMap[k] = v;
  }

  toString() {
    return 'Header(method: ${inspect(method)}, uri: ${inspect(uri)}, '
      'httpVersion: ${inspect(httpVersion)}, '
      'headerMap: ${inspect(headerMap)})';
  }

}


class HeaderParser {

  var _stream, _entryParser, header, _index = 0, _length = 0,
    _linedUpParser, _tokenIndex = 0, _keyToken;

  parse(charCodes) {
    header = new Header();
    _stream = charCodes;
    _entryParser = inMethod;
    _index = 0;
    _length = _stream.length;
    while (_index < _length) {
      _entryParser();
    }
  }

  collectString(endIndex) {
    var ti = _tokenIndex;
    _index = endIndex + 1;
    return new String.fromCharCodes(_stream, ti, endIndex);
  }

  inMethod() {
    var i = _index, c = _stream[i];
    if (c >= 65 && c <= 90) { // A-Z
      _entryParser = inMethodStarted;
      _tokenIndex = i;
      _index = i + 1;
    } else {
      throw "Invalid input. Could not parse the HTTP Method.";
    }
  }

  inMethodStarted() {
    var i = _index, st = _stream, c, len = _length;
    do {
      c = st[i];
      if (c >= 65 && c <= 90) { // A-Z
        // ignore
      } else if (c == 32) {
        _entryParser = inSpace;
        _linedUpParser = inUri;
        header.method = collectString(i);
        break;
      } else {
        throw "Invalid input. Could not parse the HTTP Method.";
      }
      i++;
    } while (i < len);
  }

  inSpace() {
    var i = _index, st = _stream, c = st[i], len = _length;
    while (c == 32) {
      i++;
      if (i >= len) {
        return;
      }
      c = st[i];
    }
    _index = i;
    _entryParser = _linedUpParser;
  }

  inUri() {
    var i = _index;
    if (_stream[i] > 32) {
      _tokenIndex = i;
      _index = i + 1;
      _entryParser = inUriStarted;
    } else {
      throw "Invalid input. Could not parse the URI.";
    }
  }

  inUriStarted() {
    var i = _index, st = _stream, c, len = _length;
    do {
      c = st[i];
      if (c > 32) {
        // ignore
      } else if (c == 32) {
        _entryParser = inSpace;
        _linedUpParser = inHttpVersion;
        header.uri = collectString(i);
        break;
      } else {
        throw "Invalid input. Could not parse the URI.";
      }
      i++;
    } while (i < len);
  }

  inHttpVersion() {
    var i = _index;
    if (_stream[i] == 72) { // H
      _tokenIndex = i;
      _index = i + 1;
      _entryParser = inHttpVersionStarted;
    } else {
      throw "Invalid input. Could not parse the HTTP version.";
    }
  }

  inHttpVersionStarted() {
    var i = _index, st = _stream, c, len = _length;
    do {
      c = st[i];
      if (c > 32) {
        // ignore
      } else if (c == 32) {
        _entryParser = inSpace;
        _linedUpParser = inCarriageReturn;
        header.httpVersion = collectString(i);
        break;
      } else if (c == 13) {
        _entryParser = inLineFeed;
        header.httpVersion = collectString(i);
        break;
      } else if (c == 10) {
        _entryParser = inKey;
        header.httpVersion = collectString(i);
        break;
      } else {
        throw "Invalid input. Could not parse the HTTP version.";
      }
      i++;
    } while (i < len);
  }

  inLineFeed() {
    if (_stream[_index] == 10) { // \n
      _index++;
      _entryParser = inKey;
    } else {
      throw "Invalid input. Could not parse the Line Feed (/n).";
    }
  }

  inCarriageReturn() {
    var c = _stream[_index];
    if (c == 13) { // \r
      _index++;
      _entryParser = inLineFeed;
    } else if (c == 10) { // \n
      _index++;
      _entryParser = inKey;
    } else {
      throw "Invalid input. Could not parse the Carriage Return (/r).";
    }
  }

  inKey() {
    var i = _index, c = _stream[i];
    if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) { // A-Z a-z
      _tokenIndex = i;
      _index = i + 1;
      _entryParser = inKeyStarted;
    } else if (c == 10) { // \n
      _index = _length; // Header exit.
    } else if (c == 13) { // \r
      _index++;
      _entryParser = inHeaderExit;
    } else {
      throw "Invalid input. Could not parse the key.";
    }
  }

  inHeaderExit() {
    if (_stream[_index] == 10) { // \n
      _index = _length;
    } else {
      throw "Invalid input. Could not parse the Line Feed (/n).";
    }
  }

  inKeyStarted() {
    var i = _index, st = _stream, c, len = _length;
    do {
      c = st[i];
      if (c == 58) { // :
        _entryParser = inSpace;
        _linedUpParser = inValue;
        _keyToken = collectString(i);
        break;
      } else if (c > 32) {
        // ignore
      } else if (c == 32) {
        _entryParser = inSpace;
        _linedUpParser = inColon;
        _keyToken = collectString(i);
        break;
      } else {
        throw "Invalid input. Could not parse the key.";
      }
      i++;
    } while (i < len);
  }

  inColon() {
    if (_stream[_index] == 58) { // :
      _index++;
      _entryParser = inSpace;
      _linedUpParser = inValue;
    } else {
      throw "Invalid input. Could not parse the colon (:).";
    }
  }

  inValue() {
    var i = _index;
    if (_stream[i] > 32) {
      _tokenIndex = i;
      _index = i + 1;
      _entryParser = inValueStarted;
    } else {
      throw "Invalid input. Could not parse the value.";
    }
  }

  inValueStarted() {
    var i = _index, st = _stream, c, len = _length;
    do {
      c = st[i];
      if (c >= 32) {
        // ignore
      } else if (c == 13) {
        _entryParser = inLineFeed;
        header[_keyToken] = collectString(i);
        break;
      } else if (c == 10) {
        _entryParser = inKey;
        header[_keyToken] = collectString(i);
        break;
      } else {
        throw "Invalid input. Could not parse the value.";
      }
      i++;
    } while (i < len);
  }

}
