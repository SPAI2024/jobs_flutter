import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/database_helper.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Login
  static Future<bool> login(String email, String password) async {
    try {
      final user = await DatabaseHelper.instance.getUser(email, password);

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_userEmailKey, email);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Sign up
  static Future<bool> signUp(String name, String email, String password) async {
    try {
      // Check if email already exists
      bool exists = await DatabaseHelper.instance.emailExists(email);
      if (exists) return false;

      // Create new user
      await DatabaseHelper.instance.createUser({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Auto login after signup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userEmailKey, email);

      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Demo signup
  static Future<bool> demoSignUp() async {
    try {
      String demoEmail = 'demo@example.com';
      String demoPassword = 'demo123';
      String demoName = 'Demo User';

      // Try to login first if demo account exists
      bool loginSuccess = await login(demoEmail, demoPassword);
      if (loginSuccess) return true;

      // Create demo account if doesn't exist
      return await signUp(demoName, demoEmail, demoPassword);
    } catch (e) {
      print('Demo signup error: $e');
      return false;
    }
  }
}