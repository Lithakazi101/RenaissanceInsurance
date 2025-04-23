import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';
  
  // Mock API URL - in a real app, this would be your actual API
  final String _baseUrl = 'https://api.renaissance-insurance.com';

  // Get the stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Store the token securely
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Remove the token (logout)
  Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Get stored user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  // Store user data
  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Remove user data
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Login function - in a real app, this would call your API
  Future<User?> login(String email, String password) async {
    // For demo purposes, we're mocking a successful login
    // In a real app, you would call your API and validate credentials
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful response for specific credentials
    if (email == 'demo@renaissance.com' && password == 'password123') {
      final user = User(
        id: '1',
        email: email,
        name: 'Demo User',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Store the token and user data
      await setToken(user.token);
      await setUser(user);
      
      return user;
    }
    
    // Return null for failed login
    return null;
  }

  // Logout function
  Future<void> logout() async {
    await removeToken();
    await removeUser();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
} 