import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // SIGN UP
  Future<String?> signUp(String name, String email, String password, String role) async {
    final prefs = await SharedPreferences.getInstance();

    final user = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };

    final usersString = prefs.getString('users');
    List users = [];

    if (usersString != null) {
      users = jsonDecode(usersString);
    }

    for (var existingUser in users) {
      if (existingUser['email'] == email) {
        return "User already exists";
      }
    }

    users.add(user);
    await prefs.setString('users', jsonEncode(users));
    
    // Automatically log in after sign up
    await prefs.setString('currentUser', jsonEncode(user));

    return null; // success
  }

  // LOGIN
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final usersString = prefs.getString('users');
    if (usersString == null) return null;

    final List users = jsonDecode(usersString);

    for (var user in users) {
      if (user['email'] == email && user['password'] == password) {
        await prefs.setString('currentUser', jsonEncode(user));
        return user;
      }
    }

    return null;
  }

  // GET CURRENT USER
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('currentUser');
    if (userString == null) return null;
    return jsonDecode(userString);
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }
}
