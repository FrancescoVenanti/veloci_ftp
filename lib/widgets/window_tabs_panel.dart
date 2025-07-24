// lib/widgets/window_tabs_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:veloci_client/theme/theme.dart';
import '../models/ftp_session.dart';
import '../models/session_window.dart';
import '../services/session_manager.dart';
import '../services/session_service.dart';
import 'zen_session_form_dialog.dart';

class WindowTabsPanel extends StatefulWidget {
  final Function(SessionWindow?) onWindowChanged;

  const WindowTabsPanel({super.key, required this.onWindowChanged});

  @override
  State<WindowTabsPanel> createState() => _WindowTabsPanelState();
}

class _WindowTabsPanelState extends State<WindowTabsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  List<FTPSession> _savedSessions = [];
  bool _isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
    _loadSavedSessions();

    // Listen to session manager changes
    SessionManager.instance.addListener(_onSessionManagerChanged);
  }

  @override
  void dispose() {
    SessionManager.instance.removeListener(_onSessionManagerChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onSessionManagerChanged() {
    if (mounted) {
      setState(() {});
      widget.onWindowChanged(SessionManager.instance.currentWindow);
    }
  }

  Future<void> _loadSavedSessions() async {
    final sessions = await SessionService.instance.getSessions();
    if (mounted) {
      setState(() {
        _savedSessions = sessions;
        _isLoadingSessions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: ZenDecorations.sidePanel,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Column(
          children: [
            _buildHeader(),
            _buildActiveWindowsList(),
            const Divider(color: ZenColors.softGray, height: 1),
            _buildSavedSessionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final sessionManager = SessionManager.instance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ZenColors.softGray, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ZenColors.primarySage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ZenColors.primarySage.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.tab_rounded,
              color: ZenColors.primarySage,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Windows',
                  style: ZenTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sessionManager.activeWindows.length} active',
                  style: ZenTextStyles.labelMedium.copyWith(
                    color: ZenColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showAddSessionDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ZenColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ZenColors.accentTeal.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: ZenColors.accentTeal,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWindowsList() {
    final sessionManager = SessionManager.instance;
    final activeWindows = sessionManager.activeWindows;

    if (activeWindows.isEmpty) {
      return Expanded(flex: 2, child: _buildEmptyWindowsState());
    }

    return Expanded(
      flex: 2,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: activeWindows.length,
        itemBuilder: (context, index) {
          final window = activeWindows[index];
          final isSelected = sessionManager.currentWindowId == window.id;

          return _buildWindowTab(window, isSelected);
        },
      ),
    );
  }

  Widget _buildWindowTab(SessionWindow window, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            SessionManager.instance.switchToWindow(window.id);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? ZenColors.primarySage.withOpacity(0.1)
                  : ZenColors.paperWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? ZenColors.primarySage.withOpacity(0.3)
                    : ZenColors.softGray.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(window.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        window.session.name,
                        style: ZenTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? ZenColors.primarySage
                              : ZenColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${window.session.host}:${window.session.port}',
                        style: ZenTextStyles.labelMedium.copyWith(
                          color: ZenColors.mediumGray,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (window.hasError) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Connection failed',
                          style: ZenTextStyles.labelMedium.copyWith(
                            color: ZenColors.errorRed,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (window.hasError)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            SessionManager.instance.retryConnection(window.id);
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: ZenColors.warningOrange,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCloseWindowConfirmation(window);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close_rounded,
                            color: ZenColors.mediumGray,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWindowsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZenColors.mediumGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.tab_outlined,
                size: 32,
                color: ZenColors.mediumGray,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No active sessions',
              style: ZenTextStyles.titleLarge.copyWith(
                color: ZenColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open a session to get started',
              textAlign: TextAlign.center,
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedSessionsList() {
    return Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Saved Sessions',
                  style: ZenTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ZenColors.darkGray,
                  ),
                ),
                const Spacer(),
                if (!_isLoadingSessions)
                  Text(
                    '${_savedSessions.length}',
                    style: ZenTextStyles.labelMedium.copyWith(
                      color: ZenColors.mediumGray,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingSessions
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ZenColors.primarySage,
                    ),
                  )
                : _savedSessions.isEmpty
                ? _buildEmptySessionsState()
                : _buildSessionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ZenColors.mediumGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 24,
                color: ZenColors.mediumGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No saved sessions',
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create sessions for quick access',
              textAlign: TextAlign.center,
              style: ZenTextStyles.labelMedium.copyWith(
                color: ZenColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _savedSessions.length,
      itemBuilder: (context, index) {
        final session = _savedSessions[index];
        final isOpen = SessionManager.instance.isSessionOpen(session.id);

        return _buildSessionItem(session, isOpen);
      },
    );
  }

  Widget _buildSessionItem(FTPSession session, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _openSession(session),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOpen
                  ? ZenColors.accentTeal.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isOpen
                  ? Border.all(
                      color: ZenColors.accentTeal.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOpen ? ZenColors.accentTeal : ZenColors.mediumGray,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: ZenTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ZenColors.charcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${session.username}@${session.host}',
                        style: ZenTextStyles.labelMedium.copyWith(
                          color: ZenColors.mediumGray,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ZenColors.softGray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: ZenColors.mediumGray,
                      size: 12,
                    ),
                  ),
                  onSelected: (value) => _handleSessionAction(value, session),
                  itemBuilder: (context) => [
                    if (isOpen)
                      PopupMenuItem(
                        value: 'switch',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tab_rounded,
                              size: 14,
                              color: ZenColors.accentTeal,
                            ),
                            const SizedBox(width: 8),
                            Text('Switch to', style: ZenTextStyles.labelMedium),
                          ],
                        ),
                      ),
                    if (!isOpen)
                      PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.launch_rounded,
                              size: 14,
                              color: ZenColors.accentBlue,
                            ),
                            const SizedBox(width: 8),
                            Text('Open', style: ZenTextStyles.labelMedium),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: ZenColors.warningOrange,
                          ),
                          const SizedBox(width: 8),
                          Text('Edit', style: ZenTextStyles.labelMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: ZenColors.errorRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: ZenTextStyles.labelMedium.copyWith(
                              color: ZenColors.errorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.connected:
        return ZenColors.successGreen;
      case SessionStatus.connecting:
        return ZenColors.warningOrange;
      case SessionStatus.error:
        return ZenColors.errorRed;
      case SessionStatus.disconnected:
        return ZenColors.mediumGray;
    }
  }

  void _openSession(FTPSession session) async {
    HapticFeedback.lightImpact();

    final existingWindow = SessionManager.instance.getWindowBySessionId(
      session.id,
    );
    if (existingWindow != null) {
      SessionManager.instance.switchToWindow(existingWindow.id);
      return;
    }

    try {
      await SessionManager.instance.openSessionWindow(session);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open session: $e'),
            backgroundColor: ZenColors.errorRed,
          ),
        );
      }
    }
  }

  void _handleSessionAction(String action, FTPSession session) {
    switch (action) {
      case 'switch':
        final window = SessionManager.instance.getWindowBySessionId(session.id);
        if (window != null) {
          SessionManager.instance.switchToWindow(window.id);
        }
        break;
      case 'open':
        _openSession(session);
        break;
      case 'edit':
        _showEditSessionDialog(session);
        break;
      case 'delete':
        _showDeleteSessionConfirmation(session);
        break;
    }
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => ZenSessionFormDialog(
        onSave: (session) async {
          await SessionService.instance.addSession(session);
          _loadSavedSessions();
        },
      ),
    );
  }

  void _showEditSessionDialog(FTPSession session) {
    showDialog(
      context: context,
      builder: (context) => ZenSessionFormDialog(
        session: session,
        onSave: (updatedSession) async {
          await SessionService.instance.updateSession(updatedSession);
          _loadSavedSessions();
        },
      ),
    );
  }

  void _showDeleteSessionConfirmation(FTPSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ZenColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ZenColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: ZenColors.errorRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Session'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${session.name}"?\n\nThis action cannot be undone.',
          style: ZenTextStyles.bodyMedium.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ZenColors.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Close window if open
              final window = SessionManager.instance.getWindowBySessionId(
                session.id,
              );
              if (window != null) {
                await SessionManager.instance.closeWindow(window.id);
              }

              await SessionService.instance.deleteSession(session.id);
              _loadSavedSessions();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Session "${session.name}" deleted'),
                    backgroundColor: ZenColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZenColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCloseWindowConfirmation(SessionWindow window) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ZenColors.paperWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ZenColors.warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tab_rounded,
                color: ZenColors.warningOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Close Window'),
          ],
        ),
        content: Text(
          'Are you sure you want to close "${window.session.name}"?\n\nThe connection will be terminated.',
          style: ZenTextStyles.bodyMedium.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ZenColors.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              SessionManager.instance.closeWindow(window.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZenColors.warningOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
