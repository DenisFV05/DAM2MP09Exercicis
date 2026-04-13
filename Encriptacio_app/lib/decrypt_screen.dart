import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'crypto_service.dart';

class DecryptScreen extends StatefulWidget {
  const DecryptScreen({super.key});

  @override
  State<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends State<DecryptScreen> {
  String? _privateKeyPath;
  String? _encryptedFilePath;
  String? _outputPath;
  bool _isProcessing = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Per defecte, mostrar la clau privada de ~/.ssh/id_rsa
    final defaultPath = CryptoService.getDefaultPrivateKeyPath();
    if (File(defaultPath).existsSync()) {
      _privateKeyPath = defaultPath;
    }
  }

  Future<void> _pickPrivateKey() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: 'Escull la clau privada RSA (id_rsa o .pem)',
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _privateKeyPath = result.files.single.path;
      });
    }
  }

  Future<void> _pickEncryptedFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: 'Escull l\'arxiu encriptat',
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _encryptedFilePath = result.files.single.path;
        // Suggest output path by removing .encrypted extension
        if (_encryptedFilePath!.endsWith('.encrypted')) {
          _outputPath = _encryptedFilePath!.replaceAll('.encrypted', '.decrypted');
        } else {
          _outputPath = '${_encryptedFilePath!}.decrypted';
        }
      });
    }
  }

  Future<void> _pickOutputPath() async {
    final result = await FilePicker.saveFile(
      dialogTitle: 'Escull on guardar l\'arxiu desencriptat',
      fileName: 'desencriptat',
    );
    if (result != null) {
      setState(() {
        _outputPath = result;
      });
    }
  }

  Future<void> _decrypt() async {
    if (_privateKeyPath == null || _encryptedFilePath == null || _outputPath == null) {
      setState(() {
        _statusMessage = '⚠️ Selecciona la clau privada, l\'arxiu encriptat i el destí';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Desencriptant...';
    });

    try {
      final keyFile = File(_privateKeyPath!);
      final keyPem = await keyFile.readAsString();
      final privateKey = CryptoService.parsePrivateKeyFromPem(keyPem);

      await CryptoService.decryptFile(_encryptedFilePath!, _outputPath!, privateKey);

      setState(() {
        _statusMessage = '✅ Arxiu desencriptat correctament!\nDesat a: $_outputPath';
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: ${e.toString()}';
        _isSuccess = false;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade900,
                  Colors.green.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.lock_open, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Desencriptar Arxiu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona la clau privada RSA i l\'arxiu encriptat',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Private Key selector
          _buildFileSelector(
            title: '🔐 Clau Privada RSA',
            subtitle: _privateKeyPath ?? 'Cap clau seleccionada',
            icon: Icons.vpn_key,
            onPressed: _pickPrivateKey,
            hasDefault: _privateKeyPath != null,
          ),

          const SizedBox(height: 16),

          // Encrypted file selector
          _buildFileSelector(
            title: '📄 Arxiu encriptat',
            subtitle: _encryptedFilePath ?? 'Cap arxiu seleccionat',
            icon: Icons.file_present,
            onPressed: _pickEncryptedFile,
          ),

          const SizedBox(height: 16),

          // Output path selector
          _buildFileSelector(
            title: '💾 Arxiu destí',
            subtitle: _outputPath ?? 'Cap destí seleccionat',
            icon: Icons.save,
            onPressed: _pickOutputPath,
          ),

          const SizedBox(height: 24),

          // Decrypt button
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _decrypt,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_open, size: 24),
              label: Text(
                _isProcessing ? 'Desencriptant...' : 'Desencriptar',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_statusMessage.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSuccess
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSuccess ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _isSuccess ? Colors.green.shade300 : Colors.red.shade300,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileSelector({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    bool hasDefault = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 36, color: Colors.green.shade400),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (hasDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'per defecte',
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: onPressed,
        ),
        onTap: onPressed,
      ),
    );
  }
}
