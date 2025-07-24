import 'package:flutter/material.dart';
import '../models/ftp_session.dart';
import '../services/session_service.dart';
import 'session_form_dialog.dart';

class SessionSidePanel extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(FTPSession) onSessionSelected;

  const SessionSidePanel({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onSessionSelected,
  });

  @override
  State<SessionSidePanel> createState() => _SessionSidePanelState();
}

class _SessionSidePanelState extends State<SessionSidePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<FTPSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadSessions();
  }

  @override
  void didUpdateWidget(SessionSidePanel oldWidget) {
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
    final theme = Theme.of(context);

    return Row(
      children: [
        // Toggle button
        Container(
          width: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            border: Border(
              right: BorderSide(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: AnimatedRotation(
                    turns: widget.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.chevron_right),
                  ),
                  onPressed: widget.onToggle,
                  tooltip: widget.isExpanded ? 'Collapse' : 'Expand Sessions',
                ),
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Center(
                    child: Text(
                      'SESSIONS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Animated panel content
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              width: _animation.value * 300,
              child: _animation.value > 0 ? _buildPanelContent(theme) : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPanelContent(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Sessions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showAddSessionDialog,
                tooltip: 'Add Session',
              ),
            ],
            automaticallyImplyLeading: false,
          ),
          // Sessions list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions.isEmpty
                ? _buildEmptyState(theme)
                : _buildSessionsList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Sessions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first session to get started',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _showAddSessionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList(ThemeData theme) {
    return ListView.separated(
      itemCount: _sessions.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionItem(session, theme);
      },
    );
  }

  Widget _buildSessionItem(FTPSession session, ThemeData theme) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Text(
          session.name.isNotEmpty ? session.name[0].toUpperCase() : 'S',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        session.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${session.username}@${session.host}:${session.port}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
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
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => widget.onSessionSelected(session),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAddSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => SessionFormDialog(
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
      builder: (context) => SessionFormDialog(
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
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to delete "${session.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await SessionService.instance.deleteSession(session.id);
              _loadSessions();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
