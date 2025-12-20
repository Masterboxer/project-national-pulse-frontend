import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_micro_journal/environment/development.dart';
import 'package:project_micro_journal/templates/template_model.dart';
import 'package:project_micro_journal/templates/template_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final TemplateService _templateService = TemplateService.instance;

  String? _todayPhotoPath;
  PostTemplate? _selectedTemplate;
  bool _isLoadingTemplates = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    try {
      await _templateService.fetchTemplatesFromBackend();
      if (mounted) {
        setState(() => _isLoadingTemplates = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTemplates = false;
          _error = 'Failed to load templates: $e';
        });
      }
    }
  }

  Future<void> _pickPhoto() async {
    // TODO: Add image_picker package and implement
    setState(() {
      _todayPhotoPath = 'mock_photo_path.jpg';
    });
  }

  Future<void> _submitPost() async {
    final text = _postController.text.trim();

    if (_selectedTemplate == null) {
      _showSnackBar('Please select a template first', Colors.red);
      return;
    }

    if (text.isEmpty) {
      _showSnackBar('Please write something for today', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final postData = {
        'user_id': 1, // TODO: Get from auth/JWT
        'templateId': _selectedTemplate!.id,
        'text': text,
        'photoPath': _todayPhotoPath,
      };

      final response = await http.post(
        Uri.parse('${Environment.baseUrl}posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postData),
      );

      if (response.statusCode == 201) {
        final resultData = {
          'templateId': _selectedTemplate!.id,
          'text': text,
          'photoPath': _todayPhotoPath,
          'timestamp': DateTime.now(),
        };
        if (mounted) {
          Navigator.pop(context, resultData);
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      _showSnackBar('Failed to submit post: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, Color? backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = _templateService.getAllTemplates();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: false,
        actions: [
          if (!_isSubmitting)
            TextButton(onPressed: _submitPost, child: const Text('Submit')),
        ],
      ),
      body:
          _isLoadingTemplates
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorView(theme)
              : Padding(
                padding: const EdgeInsets.all(16),
                child: _buildComposeView(theme, templates),
              ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load templates',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_error!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: _loadTemplates, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildComposeView(ThemeData theme, List<PostTemplate> templates) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's micro-post", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Up to 280 characters.', style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),

          // Template Selection Section
          Text(
            'Choose a template *',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (templates.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No templates available'),
            )
          else
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    templates.map((template) {
                      final isSelected = _selectedTemplate?.id == template.id;
                      return GestureDetector(
                        onTap:
                            _isSubmitting
                                ? null
                                : () {
                                  setState(() {
                                    _selectedTemplate =
                                        isSelected ? null : template;
                                    if (!isSelected) {
                                      _postController.text =
                                          '${template.name} ';
                                      _postController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  _postController.text.length,
                                            ),
                                          );
                                    } else {
                                      _postController.clear();
                                    }
                                  });
                                },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceVariant
                                        .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                template.iconData,
                                size: 24,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  template.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? theme
                                                .colorScheme
                                                .onPrimaryContainer
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

          const SizedBox(height: 20),

          // Selected Template Indicator
          if (_selectedTemplate != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedTemplate!.iconData,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template: ${_selectedTemplate!.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedTemplate!.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedTemplate!.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Text Input Field
          TextField(
            controller: _postController,
            maxLength: 280,
            maxLines: 5,
            enabled: !_isSubmitting && _selectedTemplate != null,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText:
                  _selectedTemplate != null
                      ? 'Continue writing your reflection...'
                      : 'Select a template first to start writing',
              counterText: null,
            ),
          ),

          const SizedBox(height: 12),

          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${_postController.text.length}/280',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      _postController.text.length > 260
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Photo Button
          TextButton.icon(
            onPressed:
                (!_isSubmitting && _selectedTemplate != null)
                    ? _pickPhoto
                    : null,
            icon: const Icon(Icons.photo_outlined),
            label: Text(
              _todayPhotoPath != null
                  ? 'Photo added ✓'
                  : 'Add photo (optional)',
              style: TextStyle(
                color:
                    _selectedTemplate != null && !_isSubmitting
                        ? null
                        : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button (only shown when not submitting via AppBar)
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitPost,
                child: const Text("Submit today's post"),
              ),
            ),
        ],
      ),
    );
  }
}
