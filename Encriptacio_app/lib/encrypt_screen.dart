import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'crypto_service.dart';

class EncryptScreen extends StatefulWidget {
  const EncryptScreen({super.key});

  @override
  State<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends State<EncryptScreen> {
  String? _publicKeyPath;
  String? _filePath;
  bool _isProcessing = false;
  String _statusMessage = '';
  bool _isSuccess = false;

  Future<void> _pickPublicKey() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: 'Escull la clau pública RSA (.pub o .pem)',
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _publicKeyPath = result.files.single.path;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      dialogTitle: 'Escull l\'arxiu per encriptar',
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _encrypt() async {
    if (_publicKeyPath == null || _filePath == null) {
      setState(() {
        _statusMessage = '⚠️ Selecciona una clau pública i un arxiu';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Encriptant...';
    });

    try {
      final keyFile = File(_publicKeyPath!);
      final keyPem = await keyFile.readAsString();
      final publicKey = CryptoService.parsePublicKeyFromPem(keyPem);

      final outputPath = '${_filePath!}.encrypted';
      await CryptoService.encryptFile(_filePath!, outputPath, publicKey);

      setState(() {
        _statusMessage = '✅ Arxiu encriptat correctament!\nDesat a: $outputPath';
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
                  Colors.blue.shade900,
                  Colors.blue.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.lock, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Encriptar Arxiu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona una clau pública RSA i un arxiu per encriptar-lo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Public Key selector
          _buildFileSelector(
            title: '🔓 Clau Pública RSA',
            subtitle: _publicKeyPath ?? 'Cap clau seleccionada',
            icon: Icons.key,
            onPressed: _pickPublicKey,
          ),

          const SizedBox(height: 16),

          // File selector
          _buildFileSelector(
            title: '📄 Arxiu per encriptar',
            subtitle: _filePath ?? 'Cap arxiu seleccionat',
            icon: Icons.file_present,
            onPressed: _pickFile,
          ),

          const SizedBox(height: 24),

          // Encrypt button
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _encrypt,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.enhanced_encryption, size: 24),
              label: Text(
                _isProcessing ? 'Encriptant...' : 'Encriptar',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, size: 36, color: Colors.blue.shade400),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
