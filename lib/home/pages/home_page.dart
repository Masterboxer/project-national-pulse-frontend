import 'package:flutter/material.dart';
import 'package:project_micro_journal/posts/pages/create_post_page.dart';
import 'package:project_micro_journal/templates/template_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TemplateService _templateService = TemplateService.instance;

  Map<String, dynamic>? _todayPost;
  List<Map<String, dynamic>> _friendsPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _templateService.fetchTemplatesFromBackend(),
        _loadTodayPost(),
        _loadFriendsPosts(),
      ]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTodayPost() async {
    // TODO: Implement API call to check if user has posted today
    // For now, keep null (no post today)
    setState(() {
      _todayPost = null;
    });
  }

  Future<void> _loadFriendsPosts() async {
    // TODO: Implement API call to fetch friends' posts
    // Mock data replaced with empty list for now
    setState(() {
      _friendsPosts = [];
    });
  }

  Future<void> _createNewPost() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _todayPost = result;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Failed to load data', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_error!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _initializeData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // ... rest of your existing Scaffold code remains the same
      // Just update the ListView.builder itemCount:
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child:
            _todayPost == null
                ? _buildEmptyState(theme)
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      _friendsPosts.isEmpty ? 2 : 3 + _friendsPosts.length,
                  itemBuilder: (context, index) {
                    // "Today's Post" header
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          "Today's Post",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    // Today's post card
                    if (index == 1) {
                      return _buildTodayPostCard(theme, _todayPost!);
                    }

                    // "Friends Activity" header (only if friends posts exist)
                    if (_friendsPosts.isNotEmpty && index == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Text(
                          'Friends Activity',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    // Friends' posts
                    final friendPostIndex =
                        _friendsPosts.isEmpty ? index - 2 : index - 3;
                    if (friendPostIndex < _friendsPosts.length) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFriendPostCard(
                          theme,
                          _friendsPosts[friendPostIndex],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
      ),
      floatingActionButton:
          _todayPost == null
              ? FloatingActionButton.extended(
                onPressed: _createNewPost,
                icon: const Icon(Icons.edit),
                label: const Text('Create Today\'s Post'),
              )
              : null,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No post yet today',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share your thoughts and reflections for today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _createNewPost,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Post'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayPostCard(ThemeData theme, Map<String, dynamic> post) {
    final templateId = post['templateId'] as int?;
    final template =
        templateId != null
            ? _templateService.getTemplateById(templateId)
            : null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Post',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (template != null) ...[
                    Icon(
                      template.iconData,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      template?.name ?? post['template'] ?? 'Unknown template',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(post['text'], style: theme.textTheme.bodyLarge),
            if (post['photoPath'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.photo,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Photo attached',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posts cannot be edited after submission',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // Replace: template?.name ?? post['template'] ?? 'Unknown template',
    // With:     template?.name ?? 'Unknown template',
  }

  Widget _buildFriendPostCard(ThemeData theme, Map<String, dynamic> post) {
    final templateId = post['templateId'] as int?;
    final template =
        templateId != null
            ? _templateService.getTemplateById(templateId)
            : null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    post['userName'][0],
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['userName'],
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post['timestamp']),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (template != null) ...[
                    Icon(
                      template.iconData,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      template?.name ?? 'Unknown template',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(post['text'], style: theme.textTheme.bodyMedium),
            if (post['photoPath'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.photo,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Photo attached',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
