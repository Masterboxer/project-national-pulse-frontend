import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_micro_journal/environment/development.dart';
import 'template_model.dart';

class TemplateService {
  TemplateService._privateConstructor();

  static final TemplateService _instance =
      TemplateService._privateConstructor();

  factory TemplateService() {
    return _instance;
  }

  static TemplateService get instance => _instance;

  static const String _baseUrl = Environment.baseUrl;
  List<PostTemplate> _templates = [];

  List<PostTemplate> getAllTemplates() {
    return List.unmodifiable(_templates);
  }

  PostTemplate? getTemplateById(int id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  PostTemplate? getTemplateByName(String name) {
    try {
      return _templates.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<List<PostTemplate>> fetchTemplatesFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/templates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        _templates =
            jsonList.map((json) => PostTemplate.fromJson(json)).toList();
        return getAllTemplates();
      } else {
        throw Exception('Failed to load templates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching templates: $e');
    }
  }

  // Refresh templates
  Future<void> refreshTemplates() async {
    await fetchTemplatesFromBackend();
  }
}
