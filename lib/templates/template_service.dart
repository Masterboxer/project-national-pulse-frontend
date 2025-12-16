import 'package:flutter/material.dart';

import 'template_model.dart';

class TemplateService {
  // Private constructor
  TemplateService._privateConstructor();

  // Single instance
  static final TemplateService _instance =
      TemplateService._privateConstructor();

  // Factory constructor returns the same instance
  factory TemplateService() {
    return _instance;
  }

  // Getter for the singleton instance
  static TemplateService get instance => _instance;

  // Template list - this will be replaced with backend data in the future
  final List<PostTemplate> _templates = const [
    PostTemplate(
      id: 'template_001',
      name: 'How was your day today?',
      description: 'A simple check-in about how your day went overall.',
      icon: Icons.wb_sunny_outlined,
    ),
    PostTemplate(
      id: 'template_002',
      name: 'What made you smile today?',
      description: 'Capture the little or big moments that brought you joy.',
      icon: Icons.emoji_emotions_outlined,
    ),
    PostTemplate(
      id: 'template_003',
      name: 'A small win I had today was…',
      description: 'Celebrate any tiny victory, no matter how small.',
      icon: Icons.celebration_outlined,
    ),
    PostTemplate(
      id: 'template_004',
      name: 'Something that surprised me today was…',
      description: 'Note anything unexpected that stood out.',
      icon: Icons.lightbulb_outline,
    ),
    PostTemplate(
      id: 'template_005',
      name: 'One moment I want to remember from today is…',
      description: 'Save a memory you don’t want to forget.',
      icon: Icons.bookmark_border,
    ),
    PostTemplate(
      id: 'template_006',
      name: 'Someone I appreciated today was…',
      description: 'Reflect on a person who mattered to you today.',
      icon: Icons.favorite_border,
    ),
    PostTemplate(
      id: 'template_007',
      name: 'Tomorrow, I want to…',
      description: 'Set a gentle intention for your next day.',
      icon: Icons.arrow_forward_ios,
    ),
  ];

  // Get all templates
  List<PostTemplate> getAllTemplates() {
    return List.unmodifiable(_templates);
  }

  // Get template by ID
  PostTemplate? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get template by name (for backward compatibility)
  PostTemplate? getTemplateByName(String name) {
    try {
      return _templates.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  // Future method for fetching templates from backend
  Future<List<PostTemplate>> fetchTemplatesFromBackend() async {
    // TODO: Implement API call to fetch templates
    // For now, return the local templates
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call
    return getAllTemplates();
  }

  // Method to refresh templates (for future use)
  Future<void> refreshTemplates() async {
    // TODO: Implement refresh logic from backend
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
