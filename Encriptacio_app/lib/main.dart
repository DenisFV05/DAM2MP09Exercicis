import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/asymmetric/api.dart' as rsa;
import 'package:pointycastle/export.dart' hide State, Padding;
import 'package:pointycastle/asn1.dart';

void main() {
  runApp(const EncriptadorApp());
}

class EncriptadorApp extends StatelessWidget {
  const EncriptadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Secure Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, 
          brightness: Brightness.dark,
          primary: Colors.indigoAccent,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, color: Colors.indigoAccent),
            SizedBox(width: 15),
            Text('RSA SECURE PRO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.indigoAccent.withOpacity(0.5),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1B), Color(0xFF1A1A2E)],
          ),
        ),
        child: const Row(
          children: [
            Expanded(child: SeccioAccio(esEncriptar: true)),
            VerticalDivider(width: 1, thickness: 1, color: Colors.white10),
            Expanded(child: SeccioAccio(esEncriptar: false)),
          ],
        ),
      ),
    );
  }
}

class SeccioAccio extends StatefulWidget {
  final bool esEncriptar;
  const SeccioAccio({super.key, required this.esEncriptar});

  @override
  State<SeccioAccio> createState() => _SeccioAccioState();
}

class _SeccioAccioState extends State<SeccioAccio> {
  String clauPath = '';
  String arxiuOrigenPath = '';
  String arxiuDestiPath = '';
  bool processant = false;

  @override
  void initState() {
    super.initState();
    if (!widget.esEncriptar) {
      final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
      final defaultKey = '$home${Platform.pathSeparator}.ssh${Platform.pathSeparator}id_rsa';
      if (File(defaultKey).existsSync()) clauPath = defaultKey;
    }
  }

  Future<void> seleccionarArxiu(String titol, Function(String) onResult) async {
    FilePickerResult? result = await FilePicker.pickFiles(dialogTitle: titol);
    if (result != null && result.files.single.path != null) {
      setState(() {
        onResult(result.files.single.path!);
        if (widget.esEncriptar && arxiuOrigenPath.isNotEmpty) {
          arxiuDestiPath = '$arxiuOrigenPath.enc';
        }
      });
    }
  }

  dynamic parseKey(String path, bool esPublica) {
    final content = File(path).readAsStringSync().trim();
    
    if (esPublica && content.startsWith('ssh-rsa')) {
      return _parseOpenSSHPublicKey(content);
    }

    try {
      final parser = enc.RSAKeyParser();
      return parser.parse(content);
    } catch (e) {
      if (content.contains('BEGIN OPENSSH PRIVATE KEY')) {
        throw Exception('Clau OpenSSH moderna detectada. Converteix-la a PEM o genera\'n una de nova.');
      }
      try {
        final b64 = content.split('\n').where((l) => !l.startsWith('---')).join().replaceAll(RegExp(r'[\r\n\s]'), '');
        final bytes = base64.decode(b64);
        final topSeq = ASN1Parser(bytes).nextObject() as ASN1Sequence;

        if (esPublica) {
          if (topSeq.elements!.length == 2 && topSeq.elements![1] is ASN1BitString) {
            final inner = ASN1Parser((topSeq.elements![1] as ASN1BitString).valueBytes!.sublist(1)).nextObject() as ASN1Sequence;
            return rsa.RSAPublicKey((inner.elements![0] as ASN1Integer).integer!, (inner.elements![1] as ASN1Integer).integer!);
          }
          return rsa.RSAPublicKey((topSeq.elements![0] as ASN1Integer).integer!, (topSeq.elements![1] as ASN1Integer).integer!);
        } else {
          final seq = (topSeq.elements!.length == 3 && topSeq.elements![2] is ASN1OctetString) 
            ? ASN1Parser((topSeq.elements![2] as ASN1OctetString).valueBytes!).nextObject() as ASN1Sequence 
            : topSeq;
          return rsa.RSAPrivateKey((seq.elements![1] as ASN1Integer).integer!, (seq.elements![3] as ASN1Integer).integer!, (seq.elements![4] as ASN1Integer).integer!, (seq.elements![5] as ASN1Integer).integer!);
        }
      } catch (e2) { throw Exception('Format de clau invàlid'); }
    }
  }

  // CORRECCIÓN 1: Orden de parámetros (módulo, exponente)
  rsa.RSAPublicKey _parseOpenSSHPublicKey(String content) {
    final keyData = base64.decode(content.split(' ')[1]);
    int offset = 0;
    
    BigInt readBI() {
      final len = (keyData[offset] << 24) | (keyData[offset+1] << 16) | (keyData[offset+2] << 8) | keyData[offset+3];
      offset += 4;
      final b = keyData.sublist(offset, offset + len);
      offset += len;
      BigInt r = BigInt.zero;
      for (var x in b) r = (r << 8) | BigInt.from(x);
      return r;
    }
    
    offset += 11;
    final exponent = readBI();
    final modulus = readBI();
    return rsa.RSAPublicKey(modulus, exponent);
  }

  void executar() async {
    if (clauPath.isEmpty || arxiuOrigenPath.isEmpty) {
      mostrarMsg('⚠️ Falten dades', Colors.orange);
      return;
    }
    setState(() => processant = true);
    try {
      if (widget.esEncriptar) {
        final encriptador = enc.Encrypter(enc.RSA(publicKey: parseKey(clauPath, true)));
        final bytes = File(arxiuOrigenPath).readAsBytesSync();
        final output = <int>[];
        for (var i = 0; i < bytes.length; i += 190) {
          final chunk = bytes.sublist(i, (i + 190 > bytes.length) ? bytes.length : i + 190);
          final encChunk = encriptador.encryptBytes(chunk).bytes;
          output.addAll([(encChunk.length >> 8) & 0xFF, encChunk.length & 0xFF, ...encChunk]);
        }
        File('$arxiuOrigenPath.enc').writeAsBytesSync(Uint8List.fromList(output));
        mostrarMsg('✅ Arxiu protegit amb èxit', Colors.green);
      } else {
        // CORRECCIÓN 2: Validación de rangos y manejo de errores
        final encriptador = enc.Encrypter(enc.RSA(privateKey: parseKey(clauPath, false)));
        final bytes = File(arxiuOrigenPath).readAsBytesSync();
        final finalBytes = <int>[];
        int offset = 0;
        
        while (offset < bytes.length) {
          if (offset + 1 >= bytes.length) {
            break; 
          }
          
          final len = (bytes[offset] << 8) | bytes[offset + 1];
          offset += 2;
          
          if (offset + len > bytes.length) {
            throw Exception('El fitxer està corrupte o incomplet (fallada de longitud).');
          }
          
          try {
            final chunk = bytes.sublist(offset, offset + len);
            final decChunk = encriptador.decryptBytes(enc.Encrypted(Uint8List.fromList(chunk)));
            finalBytes.addAll(decChunk);
          } catch (e) {
            throw Exception('Clau privada incorrecta o bloc danyat.');
          }
          
          offset += len;
        }
        
        final desti = arxiuDestiPath.isEmpty ? '$arxiuOrigenPath.dec' : arxiuDestiPath;
        File(desti).writeAsBytesSync(Uint8List.fromList(finalBytes));
        mostrarMsg('✅ Arxiu recuperat amb èxit', Colors.green);
      }
    } catch (e) { mostrarMsg('❌ Error: $e', Colors.red); }
    finally { setState(() => processant = false); }
  }

  void _generarClaus() async {
    setState(() => processant = true);
    try {
      final keyGen = KeyGenerator('RSA')..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64), SecureRandom('Fortuna')..seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => DateTime.now().microsecondsSinceEpoch % 256))))));
      final pair = keyGen.generateKeyPair();
      final pub = pair.publicKey as rsa.RSAPublicKey;
      final priv = pair.privateKey as rsa.RSAPrivateKey;
      String format(String b, String t) {
        var r = '-----BEGIN RSA $t-----\n';
        for (var i = 0; i < b.length; i += 64) r += '${b.substring(i, (i+64>b.length)?b.length:i+64)}\n';
        return '$r-----END RSA $t-----';
      }
      final pubS = ASN1Sequence(); pubS.add(ASN1Integer(pub.modulus)); pubS.add(ASN1Integer(pub.exponent));
      final privS = ASN1Sequence(); privS.add(ASN1Integer(BigInt.zero)); privS.add(ASN1Integer(priv.modulus)); privS.add(ASN1Integer(BigInt.from(65537))); privS.add(ASN1Integer(priv.privateExponent)); privS.add(ASN1Integer(priv.p)); privS.add(ASN1Integer(priv.q)); privS.add(ASN1Integer(priv.privateExponent! % (priv.p! - BigInt.one))); privS.add(ASN1Integer(priv.privateExponent! % (priv.q! - BigInt.one))); privS.add(ASN1Integer(priv.q!.modInverse(priv.p!)));
      final dir = await FilePicker.getDirectoryPath();
      if (dir != null) {
        File('$dir/public.pem').writeAsStringSync(format(base64.encode(pubS.encode()), 'PUBLIC KEY'));
        File('$dir/private.pem').writeAsStringSync(format(base64.encode(privS.encode()), 'PRIVATE KEY'));
        mostrarMsg('✅ Claus generades a $dir', Colors.indigoAccent);
      }
    } catch (e) { mostrarMsg('❌ Error: $e', Colors.red); }
    finally { setState(() => processant = false); }
  }

  void mostrarMsg(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: c, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.esEncriptar ? Colors.indigoAccent : Colors.tealAccent;
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(widget.esEncriptar ? Icons.enhanced_encryption : Icons.no_encryption_gmailerrorred, color: color, size: 30)),
              const SizedBox(width: 20),
              Text(widget.esEncriptar ? 'ENCRIPTAR' : 'DESENCRIPTAR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 40),
          _buildCamp('Clau RSA (.pem / .pub)', clauPath, Icons.vpn_key, () => seleccionarArxiu('Clau', (p) => clauPath = p)),
          const SizedBox(height: 25),
          _buildCamp('Arxiu Origen', arxiuOrigenPath, Icons.file_present, () => seleccionarArxiu('Arxiu', (p) => arxiuOrigenPath = p)),
          if (!widget.esEncriptar) ...[
            const SizedBox(height: 25),
            _buildCamp('Arxiu Destí (Opcional)', arxiuDestiPath, Icons.save, () async {
              String? p = await FilePicker.saveFile(dialogTitle: 'Destí');
              if (p != null) setState(() => arxiuDestiPath = p);
            }),
          ],
          const Spacer(),
          if (widget.esEncriptar) 
            Center(child: TextButton.icon(onPressed: _generarClaus, icon: const Icon(Icons.shield_moon, size: 16), label: const Text('Generar claus compatibles', style: TextStyle(fontSize: 12, color: Colors.white38)))),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, height: 65, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), onPressed: processant ? null : executar, child: processant ? const CircularProgressIndicator(color: Colors.black) : Text(widget.esEncriptar ? 'EXECUTAR ENCRIPTACIÓ' : 'EXECUTAR DESENCRIPTACIÓ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
        ],
      ),
    );
  }

  Widget _buildCamp(String t, String p, IconData i, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1)),
      const SizedBox(height: 10),
      InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)), child: Row(children: [Icon(i, size: 18, color: Colors.white24), const SizedBox(width: 15), Expanded(child: Text(p.isEmpty ? 'Seleccionar arxiu...' : p, style: TextStyle(color: p.isEmpty ? Colors.white12 : Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis))]))),
    ]);
  }
}