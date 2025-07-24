// lib/screens/multi_session_app.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veloci_client/theme/theme.dart';
import '../models/session_window.dart';
import '../services/session_manager.dart';
import '../widgets/window_tabs_panel.dart';
import 'session_window_content.dart';
import 'zen_connection_screen.dart';

class MultiSessionApp extends StatefulWidget {
  const MultiSessionApp({super.key});

  @override
  State<MultiSessionApp> createState() => _MultiSessionAppState();
}

class _MultiSessionAppState extends State<MultiSessionApp>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  SessionWindow? _currentWindow;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    // Initialize with current window
    _currentWindow = SessionManager.instance.currentWindow;

    // Listen to session manager changes
    SessionManager.instance.addListener(_onSessionManagerChanged);
  }

  @override
  void dispose() {
    SessionManager.instance.removeListener(_onSessionManagerChanged);
    _fadeController.dispose();
    super.dispose();
  }

  void _onSessionManagerChanged() {
    if (mounted) {
      setState(() {
        _currentWindow = SessionManager.instance.currentWindow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ZenTheme.lightTheme,
      child: Scaffold(
        backgroundColor: ZenColors.paperWhite,
        body: Container(
          decoration: ZenDecorations.paperBackground,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                // Always visible tabs panel
                WindowTabsPanel(
                  onWindowChanged: (window) {
                    setState(() {
                      _currentWindow = window;
                    });
                  },
                ),
                // Main content area
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentWindow == null) {
      return _buildWelcomeScreen();
    }

    return SessionWindowContent(
      window: _currentWindow!,
      key: ValueKey(_currentWindow!.id),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome hero section
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ZenColors.primarySage.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ZenColors.primarySage.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ZenColors.primarySage.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to VelociFTP',
                    style: ZenTextStyles.displayLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: ZenColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Multi-session FTP client with zen-like simplicity',
                    textAlign: TextAlign.center,
                    style: ZenTextStyles.bodyLarge.copyWith(
                      color: ZenColors.mediumGray,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Quick actions
            _buildQuickActions(),

            const SizedBox(height: 32),

            // Features showcase
            _buildFeaturesShowcase(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ZenDecorations.paperCard,
      child: Column(
        children: [
          Text(
            'Quick Actions',
            style: ZenTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ZenColors.charcoal,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_rounded,
                  label: 'New Connection',
                  description: 'Connect to a new FTP server',
                  color: ZenColors.primarySage,
                  onTap: _showQuickConnect,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.bookmark_rounded,
                  label: 'Saved Sessions',
                  description: 'Open from saved connections',
                  color: ZenColors.accentTeal,
                  onTap: () {
                    // Sessions are already visible in the side panel
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Select a session from the left panel',
                        ),
                        backgroundColor: ZenColors.accentTeal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: ZenTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ZenColors.charcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: ZenTextStyles.labelMedium.copyWith(
                  color: ZenColors.mediumGray,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesShowcase() {
    final features = [
      {
        'icon': Icons.tab_rounded,
        'title': 'Multi-Session Support',
        'description': 'Keep multiple FTP connections open simultaneously',
        'color': ZenColors.primarySage,
      },
      {
        'icon': Icons.speed_rounded,
        'title': 'Fast & Reliable',
        'description': 'Optimized for speed with robust error handling',
        'color': ZenColors.accentBlue,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Secure Connections',
        'description': 'Support for FTPS and secure credential storage',
        'color': ZenColors.accentTeal,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Zen Design',
        'description': 'Clean, distraction-free interface for focus',
        'color': ZenColors.warningOrange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'Features',
            style: ZenTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: ZenColors.charcoal,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ZenColors.paperWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ZenColors.softGray.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: ZenTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ZenColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
                    style: ZenTextStyles.labelMedium.copyWith(
                      color: ZenColors.mediumGray,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showQuickConnect() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ZenConnectionScreen(isQuickConnect: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
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
}
