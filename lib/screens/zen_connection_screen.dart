// lib/screens/zen_connection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veloci_client/theme/theme.dart';
import '../services/ftp_service.dart';
import '../models/ftp_session.dart';
import '../widgets/zen_session_side_panel.dart';
import 'ftp_home_page.dart';

class ZenConnectionScreen extends StatefulWidget {
  const ZenConnectionScreen({super.key});

  @override
  State<ZenConnectionScreen> createState() => _ZenConnectionScreenState();
}

class _ZenConnectionScreenState extends State<ZenConnectionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController(text: 'test.rebex.net');
  final _userController = TextEditingController(text: 'demo');
  final _passController = TextEditingController(text: 'password');
  final _portController = TextEditingController(text: '21');

  late AnimationController _formAnimationController;
  late AnimationController _breathingController;
  late Animation<double> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _breathingAnimation;

  bool _obscurePassword = true;
  bool _isConnecting = false;
  bool _isSessionPanelExpanded = false;

  @override
  void initState() {
    super.initState();

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _formSlideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _formFadeAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _formAnimationController.forward();
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _breathingController.dispose();
    _hostController.dispose();
    _userController.dispose();
    _passController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate() || _isConnecting) return;

    // Gentle haptic feedback
    HapticFeedback.lightImpact();

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
        // Success haptic
        HapticFeedback.selectionClick();

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FTPHomePage(ftpService: ftpService),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Error haptic
        HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connection failed: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: ZenColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _onSessionSelected(FTPSession session) {
    // Gentle haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      _hostController.text = session.host;
      _userController.text = session.username;
      _passController.text = session.password;
      _portController.text = session.port.toString();
      _isSessionPanelExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Session "${session.name}" loaded',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: ZenColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ZenTheme.lightTheme,
      child: Scaffold(
        backgroundColor: ZenColors.paperWhite,
        body: Container(
          decoration: ZenDecorations.paperBackground,
          child: Row(
            children: [
              // Session side panel
              ZenSessionSidePanel(
                isExpanded: _isSessionPanelExpanded,
                onToggle: () {
                  HapticFeedback.lightImpact();
                  setState(
                    () => _isSessionPanelExpanded = !_isSessionPanelExpanded,
                  );
                },
                onSessionSelected: _onSessionSelected,
              ),
              // Main content
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: AnimatedBuilder(
          animation: _formAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _formSlideAnimation.value),
              child: FadeTransition(
                opacity: _formFadeAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildConnectionCard(),
                      const SizedBox(height: 32),
                      if (!_isSessionPanelExpanded) _buildSessionHint(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZenColors.primarySage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ZenColors.primarySage.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.cloud_rounded,
                  size: 48,
                  color: ZenColors.primarySage,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'VelociFTP',
                textAlign: TextAlign.center,
                style: ZenTextStyles.displayLarge.copyWith(
                  fontWeight: FontWeight.w200,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connect with zen and simplicity',
                textAlign: TextAlign.center,
                style: ZenTextStyles.bodyLarge.copyWith(
                  color: ZenColors.mediumGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      decoration: ZenDecorations.paperCard,
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Server Connection',
              style: ZenTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: ZenColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your server details to establish a connection',
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.mediumGray,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _hostController,
              label: 'Host Address',
              hint: 'ftp.example.com',
              icon: Icons.dns_rounded,
              validator: (v) =>
                  v!.trim().isEmpty ? 'Host address is required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _userController,
                    label: 'Username',
                    hint: 'username',
                    icon: Icons.person_rounded,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Username is required' : null,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _portController,
                    label: 'Port',
                    hint: '21',
                    icon: Icons.electrical_services_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final port = int.tryParse(v);
                      return port == null || port <= 0 || port > 65535
                          ? 'Invalid port'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _passController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_rounded,
              obscureText: _obscurePassword,
              suffixIcon: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: ZenColors.mediumGray,
                      size: 20,
                    ),
                  ),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 40),
            _buildConnectButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: ZenTextStyles.labelMedium.copyWith(
              color: ZenColors.darkGray,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: ZenTextStyles.bodyMedium.copyWith(color: ZenColors.charcoal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ZenTextStyles.bodyMedium.copyWith(
              color: ZenColors.mediumGray,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: ZenColors.mediumGray, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 20,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: ZenColors.paperCream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ZenColors.softGray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ZenColors.softGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ZenColors.primarySage,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ZenColors.errorRed, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ZenColors.errorRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isConnecting
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ZenColors.primarySage, ZenColors.primarySageDark],
              ),
        boxShadow: _isConnecting
            ? null
            : [
                BoxShadow(
                  color: ZenColors.primarySage.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ZenColors.primarySage.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isConnecting ? null : _connect,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isConnecting
              ? ZenColors.softGray
              : Colors.transparent,
          foregroundColor: _isConnecting ? ZenColors.mediumGray : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isConnecting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ZenColors.mediumGray,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Connecting...',
                    style: ZenTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ZenColors.mediumGray,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Connect to Server',
                    style: ZenTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: ZenColors.paperWhite,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSessionHint() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZenColors.accentTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZenColors.accentTeal.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ZenColors.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: ZenColors.accentTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save your connections',
                  style: ZenTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ZenColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create sessions for quick access to your servers',
                  style: ZenTextStyles.labelMedium.copyWith(
                    color: ZenColors.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isSessionPanelExpanded = true);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ZenColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ZenColors.accentTeal.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Sessions',
                      style: ZenTextStyles.labelMedium.copyWith(
                        color: ZenColors.accentTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: ZenColors.accentTeal,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
