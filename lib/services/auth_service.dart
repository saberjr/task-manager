// auth_service.dart
// Handles login, logout, and token storage.
// SharedPreferences saves the token to the device so the user stays logged in.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// mock-api uses json-server — run `npm start` inside the /mock-api folder
// kIsWeb / iOS simulator  → localhost:3000
// Android emulator        → 10.0.2.2:3000  (special alias for Mac's localhost)
// Physical phone (Wi-Fi)  → your Mac's local IP (run: ipconfig getifaddr en0)
String get baseUrl {
  if (kIsWeb) return 'http://localhost:3000';
  // ignore: do_not_use_environment
  return 'http://10.0.2.2:3000';
}

// The key we use to save/load the token in SharedPreferences
const String _tokenKey = 'auth_token';

class AuthService extends ChangeNotifier {
  String? _token;

  // True if the user is currently logged in
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  // The current token (used by ApiService to attach to requests)
  String? get token => _token;

  // Called once on app start — loads the saved token from the device
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    notifyListeners(); // tells the UI to rebuild if login state changed
  }

  // Login: sends email + password to the API, saves the returned token
  // Returns null on success, or an error message string on failure
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // json-server-auth returns the token under 'accessToken'
        final token = data['accessToken'];

        if (token == null) {
          return 'Login failed: token not found in response';
        }

        // Save token to memory and to device storage
        _token = token.toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
        notifyListeners();
        return null; // null means success
      } else {
        // Try to parse the error message from the API
        try {
          final data = jsonDecode(response.body);
          return data['message'] ?? 'Login failed (${response.statusCode})';
        } catch (_) {
          return 'Login failed (${response.statusCode})';
        }
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }

  // Logout: clears token from memory and from device storage
  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}
