import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'session.dart';
import '../models/pet_model.dart';

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2/backend_api';
}

class PetService {
  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (Session.cookie != null) 'Cookie': Session.cookie!,
      };

  Pet _fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    return Pet(
      id: toInt(json['id']),
      name: json['name'] as String? ?? '',
      breed: json['breed'] as String? ?? 'Unknown',
      age: toInt(json['age']),
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: null,
    );
  }

  Future<Pet> createPet(Pet pet) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php');
    final response = await http.post(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': pet.name,
        'age': pet.age,
        'gender': pet.breed,
        'description': pet.description,
        'status': 'available',
        'breed': pet.breed,
        'image_url': pet.imageUrl,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal create pet');
    }
    final id = data['id'] as int;
    return pet.copyWith(id: id);
  }

  Future<List<Pet>> getAllPets() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php');
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal memuat pets');
    }
    final list = (data['data'] as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  Future<Pet?> getPetById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?id=$id');
    final response = await http.get(url);
    if (response.statusCode == 404) return null;
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal memuat pet');
    }
    return _fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<Pet>> getPetsByBreed(String breed) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?q=${Uri.encodeQueryComponent(breed)}');
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal memuat pets');
    }
    return (data['data'] as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pet> updatePet(int id, Pet pet) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?id=$id');
    final response = await http.put(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': pet.name,
        'age': pet.age,
        'gender': pet.breed,
        'description': pet.description,
        'status': 'available',
        'breed': pet.breed,
        'image_url': pet.imageUrl,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal update pet');
    }
    return pet.copyWith(id: id);
  }

  Future<void> adoptPet(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?id=$id');
    final response = await http.put(
      url,
      headers: _jsonHeaders,
      body: jsonEncode({'status': 'adopted'}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal mengadopsi pet');
    }
  }

  Future<void> deletePet(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?id=$id');
    final response = await http.delete(url, headers: {
      if (Session.cookie != null) 'Cookie': Session.cookie!,
    });
    if (response.statusCode >= 400) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal delete pet');
    }
  }

  Future<List<Pet>> searchPets(String query) async {
    if (query.isEmpty) {
      return getAllPets();
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/pets.php?q=${Uri.encodeQueryComponent(query)}');
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    if (response.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal mencari pets');
    }
    return (data['data'] as List).map((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> uploadImage(String filePath) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/upload_image.php');
    final req = http.MultipartRequest('POST', url);
    if (Session.cookie != null) {
      req.headers['Cookie'] = Session.cookie!;
    }
    String ext = '';
    final dot = filePath.lastIndexOf('.');
    if (dot != -1 && dot < filePath.length - 1) {
      ext = filePath.substring(dot + 1).toLowerCase();
    }
    MediaType? mediaType;
    if (ext == 'jpg' || ext == 'jpeg' || ext == 'jfif' || ext == 'jpe') {
      mediaType = MediaType('image', 'jpeg');
    } else if (ext == 'png') {
      mediaType = MediaType('image', 'png');
    } else if (ext == 'webp') {
      mediaType = MediaType('image', 'webp');
    } else if (ext == 'heic' || ext == 'heif') {
      mediaType = MediaType('image', 'heic');
    }

    final file = await http.MultipartFile.fromPath(
      'image',
      filePath,
      contentType: mediaType,
    );
    req.files.add(file);
    final resp = await req.send();
    final body = await resp.stream.bytesToString();
    final data = jsonDecode(body);
    if (resp.statusCode >= 400 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal upload gambar');
    }
    final String rel = data['url'] as String;
    return 'http://10.0.2.2$rel';
  }
}
