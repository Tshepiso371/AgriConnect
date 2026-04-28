import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> signUp(String name, String email, String password, String role) async {
    final prefs = await SharedPreferences.getInstance();

    final user = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };

    await prefs.setString('user', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString('user');
    if (userString == null) return null;

    final user = jsonDecode(userString);

    if (user['email'] == email && user['password'] == password) {
      return user;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString('user');
    if (userString == null) return null;

    return jsonDecode(userString);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}