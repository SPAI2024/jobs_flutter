import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';

class SavedJobsService {
  static const String _savedJobsKey = 'saved_jobs';

  static Future<List<Job>> getSavedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jobsJson = prefs.getString(_savedJobsKey);

      if (jobsJson == null || jobsJson.isEmpty) {
        return [];
      }

      final List<dynamic> jobsList = json.decode(jobsJson);
      return jobsList.map((json) => Job.fromJson(json)).toList();
    } catch (e) {
      print('Error loading saved jobs: $e');
      return [];
    }
  }

  static Future<bool> saveJob(Job job) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJobs = await getSavedJobs();

      // Check if job already exists
      if (savedJobs.any((j) => j.id == job.id)) {
        return false;
      }

      job.isSaved = true;
      savedJobs.add(job);

      final String jobsJson = json.encode(
        savedJobs.map((j) => j.toJson()).toList(),
      );

      return await prefs.setString(_savedJobsKey, jobsJson);
    } catch (e) {
      print('Error saving job: $e');
      return false;
    }
  }

  static Future<bool> removeJob(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJobs = await getSavedJobs();

      savedJobs.removeWhere((job) => job.id == jobId);

      final String jobsJson = json.encode(
        savedJobs.map((j) => j.toJson()).toList(),
      );

      return await prefs.setString(_savedJobsKey, jobsJson);
    } catch (e) {
      print('Error removing job: $e');
      return false;
    }
  }

  static Future<bool> isJobSaved(int jobId) async {
    final savedJobs = await getSavedJobs();
    return savedJobs.any((job) => job.id == jobId);
  }
}