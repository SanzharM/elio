import 'package:base32/base32.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';

class OTP {
  static int generateTOTPCode(String secret, int time, {int length: 6}) {
    time = (((time ~/ 1000).round()) ~/ 30).floor();
    return _generateCode(secret, time, length);
  }

  static int generateHOTPCode(String secret, int counter, {int length: 6}) {
    return _generateCode(secret, counter, length);
  }

  static int _generateCode(String secret, int time, int length) {
    length = (length <= 8 && length > 0) ? length : 6;

    var secretList = base32.decode(secret);
    var timebytes = _int2bytes(time);

    var hmac = new Hmac(sha1, secretList);
    var hash = hmac.convert(timebytes).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) | ((hash[offset + 1] & 0xff) << 16) | ((hash[offset + 2] & 0xff) << 8) | (hash[offset + 3] & 0xff);

    return (binary % pow(10, length)).toInt();
  }

  static List<int> _int2bytes(int long) {
    var byteArray = [0, 0, 0, 0, 0, 0, 0, 0];
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }
}
