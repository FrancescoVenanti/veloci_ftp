// lib/screens/connection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veloci_client/screens/ftp_home_page.dart';
import '../services/ftp_service.dart';
import '../widgets/connection_form.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: 'test.rebex.net');
  final _userController = TextEditingController(text: 'demo');
  final _passController = TextEditingController(text: 'password');
  final _portController = TextEditingController(text: '21');

  bool _obscurePassword = true;
  bool _isConnecting = false;

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate() || _isConnecting) return;
    setState(() => _isConnecting = true);

    final ftpService = FTPService(
      host: _hostController.text.trim(),
      user: _userController.text.trim(),
      pass: _passController.text,
      port: int.tryParse(_portController.text.trim()) ?? 21,
    );

    try {
      await ftpService.connect();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FTPHomePage(ftpService: ftpService),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _userController.dispose();
    _passController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 48),
                ConnectionForm(
                  formKey: _formKey,
                  hostController: _hostController,
                  userController: _userController,
                  passController: _passController,
                  portController: _portController,
                  obscurePassword: _obscurePassword,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 48),
                _buildConnectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.cloud_outlined, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'VelociFTP',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to your server',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton() {
    return ElevatedButton(
      onPressed: _isConnecting ? null : _connect,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isConnecting
          ? const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : const Text('Connect', style: TextStyle(fontSize: 16)),
    );
  }
}
