// lib/api/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // IMPORTANT: Replace with your Render server URL
  static const String _baseUrl = 'https://fixmap-server.onrender.com/api';
  // In lib/api/api_service.dart, inside the ApiService class

  Future<List<dynamic>> getAllPublicReports() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/reports/public'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch public reports.');
    }
  }
  // --- Image Upload Function ---
  Future<String> uploadImage(File imageFile) async {
    final token = await _getAuthToken();
    final uri = Uri.parse('$_baseUrl/upload');
    
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['imageUrl'];
    } else {
      throw Exception('Failed to upload image.');
    }
  }
  
  // --- Login Function ---
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      return 'Login successful!';
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to login.');
    }
  }

  // --- Register Function ---
  Future<String> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['message'] ?? 'Registration successful!';
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to register.');
    }
  }

  // --- Get My Reports Function ---
  Future<List<dynamic>> getMyReports() async {
    final token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/my-reports'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch reports.');
    }
  }

  // --- Logout Function ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  // --- Submit Report Function ---
  Future<void> submitReport({
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/reports'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit report.');
    }
  }

  // Helper function to get the token
  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Not authenticated.');
    }
    return token;
  }
}