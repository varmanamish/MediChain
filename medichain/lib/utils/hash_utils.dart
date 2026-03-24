import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtils {
  static String sha256HexFromJson(String jsonPayload) {
    final decoded = jsonDecode(jsonPayload);
    final canonical = jsonEncode(decoded);
    final digest = sha256.convert(utf8.encode(canonical));
    return '0x${digest.toString()}';
  }
}
