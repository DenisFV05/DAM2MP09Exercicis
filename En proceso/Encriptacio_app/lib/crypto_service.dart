import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class CryptoService {
  /// Parse an RSA public key from PEM format
  static RSAPublicKey parsePublicKeyFromPem(String pem) {
    final lines = pem.split('\n')
        .where((line) => !line.startsWith('---'))
        .join();
    final bytes = _base64Decode(lines);
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Sequence publicKeySeq;
    if (topLevelSeq.elements!.length == 2) {
      // PKCS#8 / X.509 SubjectPublicKeyInfo format
      final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
      final publicKeyAsn = ASN1Parser(Uint8List.fromList(
          publicKeyBitString.valueBytes!.sublist(1)));
      publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
    } else {
      publicKeySeq = topLevelSeq;
    }

    final modulus = (publicKeySeq.elements![0] as ASN1Integer).integer!;
    final exponent = (publicKeySeq.elements![1] as ASN1Integer).integer!;

    return RSAPublicKey(modulus, exponent);
  }

  /// Parse an RSA private key from PEM format
  static RSAPrivateKey parsePrivateKeyFromPem(String pem) {
    final lines = pem.split('\n')
        .where((line) => !line.startsWith('---'))
        .join();
    final bytes = _base64Decode(lines);
    final asn1Parser = ASN1Parser(Uint8List.fromList(bytes));
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    ASN1Sequence privateKeySeq;
    if (topLevelSeq.elements!.length == 3) {
      // PKCS#8 format
      final privateKeyOctetString = topLevelSeq.elements![2] as ASN1OctetString;
      final privateKeyAsn = ASN1Parser(Uint8List.fromList(
          privateKeyOctetString.valueBytes!));
      privateKeySeq = privateKeyAsn.nextObject() as ASN1Sequence;
    } else {
      privateKeySeq = topLevelSeq;
    }

    final modulus = (privateKeySeq.elements![1] as ASN1Integer).integer!;
    final privateExponent = (privateKeySeq.elements![3] as ASN1Integer).integer!;
    final p = (privateKeySeq.elements![4] as ASN1Integer).integer!;
    final q = (privateKeySeq.elements![5] as ASN1Integer).integer!;

    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  /// Encrypt file bytes using RSA public key with OAEP padding
  static Uint8List encryptBytes(Uint8List data, RSAPublicKey publicKey) {
    final encryptor = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final maxChunkSize = (publicKey.modulus!.bitLength ~/ 8) - 42; // OAEP overhead
    final output = <int>[];

    for (var offset = 0; offset < data.length; offset += maxChunkSize) {
      final end = (offset + maxChunkSize > data.length) ? data.length : offset + maxChunkSize;
      final chunk = data.sublist(offset, end);
      final encrypted = encryptor.process(Uint8List.fromList(chunk));
      // Store length prefix (4 bytes) + encrypted chunk
      final len = encrypted.length;
      output.addAll([
        (len >> 24) & 0xFF,
        (len >> 16) & 0xFF,
        (len >> 8) & 0xFF,
        len & 0xFF,
      ]);
      output.addAll(encrypted);
    }

    return Uint8List.fromList(output);
  }

  /// Decrypt file bytes using RSA private key with OAEP padding
  static Uint8List decryptBytes(Uint8List data, RSAPrivateKey privateKey) {
    final decryptor = OAEPEncoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final output = <int>[];
    var offset = 0;

    while (offset < data.length) {
      if (offset + 4 > data.length) break;
      final chunkLen = (data[offset] << 24) |
          (data[offset + 1] << 16) |
          (data[offset + 2] << 8) |
          data[offset + 3];
      offset += 4;

      if (offset + chunkLen > data.length) break;
      final chunk = data.sublist(offset, offset + chunkLen);
      offset += chunkLen;

      final decrypted = decryptor.process(Uint8List.fromList(chunk));
      output.addAll(decrypted);
    }

    return Uint8List.fromList(output);
  }

  /// Encrypt a file and save to output path
  static Future<void> encryptFile(String inputPath, String outputPath, RSAPublicKey publicKey) async {
    final inputFile = File(inputPath);
    final data = await inputFile.readAsBytes();
    final encrypted = encryptBytes(Uint8List.fromList(data), publicKey);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(encrypted);
  }

  /// Decrypt a file and save to output path
  static Future<void> decryptFile(String inputPath, String outputPath, RSAPrivateKey privateKey) async {
    final inputFile = File(inputPath);
    final data = await inputFile.readAsBytes();
    final decrypted = decryptBytes(Uint8List.fromList(data), privateKey);
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(decrypted);
  }

  /// Generate a new RSA key pair (2048 bits)
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
        SecureRandom('Fortuna')
          ..seed(KeyParameter(Uint8List.fromList(
            List<int>.generate(32, (_) => DateTime.now().microsecondsSinceEpoch % 256),
          ))),
      ));

    final pair = keyGen.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  static Uint8List _base64Decode(String input) {
    // Handle standard and URL-safe base64
    String normalized = input.replaceAll(RegExp(r'\s'), '');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return Uint8List.fromList(
      base64.decode(normalized),
    );
  }

  /// Get the default SSH private key path
  static String getDefaultPrivateKeyPath() {
    final home = Platform.environment['USERPROFILE'] ?? 
                  Platform.environment['HOME'] ?? '';
    return '$home${Platform.pathSeparator}.ssh${Platform.pathSeparator}id_rsa';
  }

  /// Get the default SSH public key path
  static String getDefaultPublicKeyPath() {
    final home = Platform.environment['USERPROFILE'] ?? 
                  Platform.environment['HOME'] ?? '';
    return '$home${Platform.pathSeparator}.ssh${Platform.pathSeparator}id_rsa.pub';
  }
}
