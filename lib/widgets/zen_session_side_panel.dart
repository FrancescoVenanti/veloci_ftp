// lib/widgets/zen_session_side_panel.dart

import 'package:flutter/material.dart';
import 'package:veloci_client/theme/theme.dart';
import '../models/ftp_session.dart';
import '../services/session_service.dart';
import 'zen_session_form_dialog.dart';

class ZenSessionSidePanel extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(FTPSession) onSessionSelected;

  const ZenSessionSidePanel({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onSessionSelected,
  });

  @override
  State<ZenSessionSidePanel> createState() => _ZenSessionSidePanelState();
}

class _ZenSessionSidePanelState extends State<ZenSessionSidePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  List<FTPSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _loadSessions();
  }

  @override
  void didUpdateWidget(ZenSessionSidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Future<void> _loadSessions() async {
    final sessions = await SessionService.instance.getSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Toggle sidebar
        _buildToggleSidebar(),
        // Animated panel content
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SizedBox(
              width: _slideAnimation.value * 320,
              child: _slideAnimation.value > 0 ? _buildPanelContent() : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildToggleSidebar() {
    return Container(
      width: 56,
      decoration: ZenDecorations.sidePanel,
      child: Column(
        children: [
          // Header space
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: AnimatedRotation(
                turns: widget.isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isExpanded
                        ? ZenColors.primarySage.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: widget.isExpanded
                        ? ZenColors.primarySage
                        : ZenColors.mediumGray,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onToggle,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.isExpanded
                        ? ZenColors.primarySage.withOpacity(0.1)
                        : ZenColors.paperWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isExpanded
                          ? ZenColors.primarySage.withOpacity(0.2)
                          : ZenColors.softGray,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_left_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: widget.isExpanded
                        ? ZenColors.primarySage
                        : ZenColors.mediumGray,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Vertical text
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'SESSIONS',
                  style: ZenTextStyles.labelMedium.copyWith(
                    letterSpacing: 3,
                    color: ZenColors.mediumGray,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          // Session count indicator
          if (_sessions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ZenColors.primarySage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ZenColors.primarySage.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_sessions.length}',
                  style: ZenTextStyles.labelMedium.copyWith(
                    color: ZenColors.primarySage,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    return Container(
      decoration: ZenDecorations.sidePanel,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildPanelHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _sessions.isEmpty
                  ? _buildEmptyState()
                  : _buildSessionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ZenColors.softGray, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sessions',
                  style: ZenTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Saved connections',
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
              borderRadius: BorderRadius.circular(10),
              child: Container(
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
                  Icons.add_rounded,
                  color: ZenColors.primarySage,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: ZenColors.primarySage,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZenColors.softGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 32,
                color: ZenColors.mediumGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No sessions yet',
              style: ZenTextStyles.titleLarge.copyWith(
                color: ZenColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save your connections for\nquick access',
              textAlign: TextAlign.center,
              style: ZenTextStyles.bodyMedium.copyWith(
                color: ZenColors.mediumGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddSessionDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _sessions.length,
      separatorBuilder: (context, index) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        color: ZenColors.softGray,
      ),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionItem(session, index);
      },
    );
  }

  Widget _buildSessionItem(FTPSession session, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSessionSelected(session),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZenColors.paperWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ZenColors.softGray.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Session avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getSessionColor(index).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getSessionColor(index).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      session.name.isNotEmpty
                          ? session.name[0].toUpperCase()
                          : 'S',
                      style: ZenTextStyles.titleLarge.copyWith(
                        color: _getSessionColor(index),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Session details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: ZenTextStyles.bodyLarge.copyWith(
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
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Port ${session.port}',
                        style: ZenTextStyles.labelMedium.copyWith(
                          color: ZenColors.mediumGray,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Options menu
                Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ZenColors.softGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: ZenColors.mediumGray,
                        size: 16,
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditSessionDialog(session);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(session);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: ZenColors.accentBlue,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit',
                              style: ZenTextStyles.bodyMedium.copyWith(
                                color: ZenColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: ZenColors.errorRed,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: ZenTextStyles.bodyMedium.copyWith(
                                color: ZenColors.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSessionColor(int index) {
    final colors = [
      ZenColors.primarySage,
      ZenColors.accentBlue,
      ZenColors.accentTeal,
      ZenColors.secondaryStone,
      ZenColors.accentAmber,
    ];
    return colors[index % colors.length];
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => ZenSessionFormDialog(
        onSave: (session) async {
          await SessionService.instance.addSession(session);
          _loadSessions();
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
          _loadSessions();
        },
      ),
    );
  }

  void _showDeleteConfirmation(FTPSession session) {
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
              await SessionService.instance.deleteSession(session.id);
              _loadSessions();

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
}
