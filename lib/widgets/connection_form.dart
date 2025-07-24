import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectionForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController hostController;
  final TextEditingController userController;
  final TextEditingController passController;
  final TextEditingController portController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;

  const ConnectionForm({
    super.key,
    required this.formKey,
    required this.hostController,
    required this.userController,
    required this.passController,
    required this.portController,
    required this.obscurePassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildTextField(
            context: context,
            controller: hostController,
            label: 'Host',
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(
                  context: context,
                  controller: userController,
                  label: 'Username',
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(
                  context: context,
                  controller: portController,
                  label: 'Port',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final port = int.tryParse(v);
                    return port == null || port <= 0 || port > 65535
                        ? 'Invalid'
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            controller: passController,
            label: 'Password',
            obscureText: obscurePassword,
            validator: (v) => v!.isEmpty ? 'Required' : null,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: onTogglePassword,
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}
