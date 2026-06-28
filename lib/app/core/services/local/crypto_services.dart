import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CryptoService {
  static enc.Key get _key => enc.Key.fromUtf8(dotenv.env['CRYPTO_AES_KEY'] ?? 'my32lengthsupersecretnooneknows1');
  static enc.IV get _iv => enc.IV.fromUtf8(dotenv.env['CRYPTO_AES_IV'] ?? '16bytesiv1234567');
  static enc.Encrypter get _encrypter => enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
  static List<int> get _hmacKey => utf8.encode(dotenv.env['CRYPTO_HMAC_KEY'] ?? 'hmac_secret_key_for_integrity_32!');

  static String encryptAES(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      debugPrint('[CryptoService] Encryption Error: $e');
      return plainText;
    }
  }

  static String decryptAES(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return '';
    try {
      final decrypted = _encrypter.decrypt64(encryptedBase64, iv: _iv);
      return decrypted;
    } catch (e) {
      debugPrint('[CryptoService] Decryption Error: $e');
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
      debugPrint('[CryptoService] ⚠️ HMAC VERIFICATION FAILED - Message tampered!');
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