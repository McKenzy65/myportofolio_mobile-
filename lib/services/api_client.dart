import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String baseUrl = apiBaseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl);

  final http.Client _client;
  final Uri _baseUri;
  static const _accept = {'Accept': 'application/json'};
  static const _jsonHeaders = {
    ..._accept,
    'Content-Type': 'application/json; charset=utf-8',
  };

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _baseUri.resolve('/api/v1/projects/'),
      headers: _accept,
    );
    _ensureSuccess(response);
    final projects = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return [
      for (final json in projects)
        Project.fromJson(json as Map<String, dynamic>),
    ];
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _baseUri.resolve('/api/v1/projects/'),
      headers: {..._jsonHeaders, 'Authorization': 'Token $token'},
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);
    return Project.fromJson(_decodeObject(response));
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _baseUri.resolve('/api/v1/auth/token/'),
      headers: _jsonHeaders,
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final token = _decodeObject(response)['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Token sesi tidak ditemukan pada respons.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _baseUri.resolve('/api/v1/auth/logout/'),
      headers: {..._accept, 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  // A Django debug page can contain internal details. Expose only the status
  // and an actionable message to the UI.
  void _ensureSuccess(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) return;
    final message = switch (status) {
      400 => 'Data yang dikirim tidak valid.',
      401 => 'Silakan masuk kembali.',
      403 => 'Akun ini tidak memiliki izin untuk tindakan tersebut.',
      404 => 'Alamat layanan tidak ditemukan.',
      429 => 'Terlalu banyak permintaan. Coba lagi sebentar.',
      _ => 'Layanan belum dapat memenuhi permintaan (HTTP $status).',
    };
    throw ApiException(status, message);
  }

  void close() => _client.close();
}
