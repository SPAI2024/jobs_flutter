import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class JobApiService {
  // Using Remotive API (Free, no auth required)
  static const String baseUrl = 'https://remotive.com/api/remote-jobs';

  // Alternative: Using a mock API for testing
  // static const String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  // Fetch all jobs
  static Future<List<Job>> getJobs({String? category, String? search}) async {
    try {
      // Build URL with query parameters
      Uri uri = Uri.parse(baseUrl);
      if (category != null && category.isNotEmpty) {
        uri = Uri.parse('$baseUrl?category=$category');
      }
      if (search != null && search.isNotEmpty) {
        uri = Uri.parse('$baseUrl?search=$search');
      }

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List jobsJson = data['jobs'] ?? [];

        return jobsJson.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      // Return mock data if API fails
      return _getMockJobs();
    }
  }

  // Get job categories
  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://remotive.com/api/remote-jobs/categories'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List categoriesJson = data['jobs'] ?? [];

        return categoriesJson
            .map((cat) => cat['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      } else {
        return _getDefaultCategories();
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return _getDefaultCategories();
    }
  }

  // Default categories if API fails
  static List<String> _getDefaultCategories() {
    return [
      'Software Development',
      'Customer Service',
      'Design',
      'Marketing',
      'Sales',
      'Product',
      'Business',
      'Data',
      'DevOps',
      'Finance',
      'Legal',
      'HR',
      'QA',
      'Writing',
      'All others'
    ];
  }

  // Mock data for fallback
  static List<Job> _getMockJobs() {
    return List.generate(
      10,
          (index) => Job(
        id: index,
        title: 'Software Developer ${index + 1}',
        company: 'Tech Company ${index + 1}',
        location: index % 2 == 0 ? 'Remote' : 'New York, USA',
        salary: '\$${50 + index * 10}k - \$${70 + index * 10}k',
        type: index % 3 == 0 ? 'Full-time' : 'Contract',
        description: 'This is a great opportunity for a skilled developer with ${index + 2} years of experience.',
        category: 'Software Development',
        url: 'https://example.com/job/$index',
        companyLogo: '',
        publishedDate: DateTime.now().subtract(Duration(days: index)),
        tags: 'flutter, dart, mobile',
      ),
    );
  }
}