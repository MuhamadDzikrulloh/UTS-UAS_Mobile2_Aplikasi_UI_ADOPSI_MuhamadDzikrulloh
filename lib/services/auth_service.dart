import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

class AuthConfig {
  static const String baseUrl = 'http://10.0.2.2/backend_api';
}

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AuthConfig.baseUrl}/auth.php');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    Map<String, dynamic> data;
    try {
      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        throw const FormatException('Response bukan JSON');
      }
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      final snippet = res.body.length > 200 ? res.body.substring(0, 200) : res.body;
      throw Exception('Gagal parsing respons dari server (status ${res.statusCode}).\nKemungkinan URL salah atau server error. Cuplikan respons:\n$snippet');
    }

    if (res.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Login gagal');
    }

    final setCookie = res.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final cookiePart = setCookie.split(';').first;
      Session.cookie = cookiePart;
    }

    Session.role = data['user']?['role'];
    Session.email = data['user']?['email'];

    return data['user'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    Session.clear();
  }

  Future<void> resetPassword(String email, String password) async {
    final url = Uri.parse('${AuthConfig.baseUrl}/reset_password.php');
    final resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Reset password gagal');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('${AuthConfig.baseUrl}/register.php');
    final res = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}));
    Map<String, dynamic> data;
    try {
      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        throw const FormatException('Response bukan JSON');
      }
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      final snippet = res.body.length > 200 ? res.body.substring(0, 200) : res.body;
      throw Exception('Gagal parsing respons dari server (status ${res.statusCode}).\nKemungkinan URL salah atau server error. Cuplikan respons:\n$snippet');
    }

    if (res.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }

    return data['user'] as Map<String, dynamic>;
  }
}
