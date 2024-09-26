class QrParser {
  static const String sepertor = ';';

  static String parseHost(String rawData) {
    var data = rawData.split(sepertor);
    if (data.length != 3) {
      throw Exception('Invalid QR Code');
    }
    var v = data[0];
    var t = data[1];
    var id = data[2];

    switch (v) {
      case "v1":
        if (t != "h") throw Exception('Invalid QR Code');
        return id;
      default:
        throw Exception('Invalid QR Code');
    }
  }

  static String encodeUid(String uid) {
    return 'v1;h;$uid';
  }
}
