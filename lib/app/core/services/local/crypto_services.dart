import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class CryptoService {
  static final _key = enc.Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final _iv = enc.IV.fromUtf8('16bytesiv1234567');
  static final _encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
  static final _hmacKey = utf8.encode('hmac_secret_key_for_integrity_32!');

  static String encryptAES(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      print('[CryptoService] Encryption Error: $e');
      return plainText;
    }
  }

  static String decryptAES(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return '';
    try {
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: _iv);
      return decrypted;
    } catch (e) {
      print('[CryptoService] Decryption Error: $e');
      return encryptedBase64;
    }
  }

  static String generateHMAC(String data) {
    final hmac = Hmac(sha256, _hmacKey);
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString();
  }

  static bool verifyHMAC(String data, String expectedHmac) {
    final computed = generateHMAC(data);
    return computed == expectedHmac;
  }

  static Map<String, String> encryptAndSign(String plainText) {
    final encrypted = encryptAES(plainText);
    final hmac = generateHMAC(encrypted);
    return {
      'data': encrypted,
      'hmac': hmac,
    };
  }

  static String? decryptAndVerify(String encryptedData, String hmac) {
    if (!verifyHMAC(encryptedData, hmac)) {
      print('[CryptoService] ⚠️ HMAC VERIFICATION FAILED - Message tampered!');
      return null;
    }
    return decryptAES(encryptedData);
  }

  static String hashSHA256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}