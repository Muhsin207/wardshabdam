import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/announcement.dart';
import '../models/complaint.dart';
import '../models/circular.dart';
import '../models/download_document.dart';
import '../models/gallery_photo.dart';
import '../models/notification.dart';
import '../models/program.dart';
import '../models/survey.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const Duration requestTimeout = Duration(seconds: 15);

  static Uri _uri(String path) {
    if (baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not configured. Build with --dart-define=API_BASE_URL=https://your-api-domain.com.',
      );
    }
    final base = Uri.parse(baseUrl);
    return base.replace(
      path: '${base.path.replaceFirst(RegExp(r'/$'), '')}$path',
    );
  }

  static String imageUrl(String filename) => _uri('/static/uploads/$filename').toString();

  static String resourceUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return _uri(path).toString();
  }

  static dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Request failed (${response.statusCode})');
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('The server returned an invalid response');
    }
  }

  static Future<dynamic> _get(String path) async {
    try {
      final response = await http.get(_uri(path)).timeout(requestTimeout);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('The request timed out');
    } on http.ClientException {
      throw const ApiException('Unable to connect to the server');
    } on Exception {
      throw const ApiException('Unable to connect to the server');
    }
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(requestTimeout);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException('The request timed out');
    } on http.ClientException {
      throw const ApiException('Unable to connect to the server');
    } on Exception {
      throw const ApiException('Unable to connect to the server');
    }
  }

  static Future<Map<String, dynamic>> login(String mobile, String password) async {
    final data = await _post('/api/login', {'mobile': mobile, 'password': password});
    if (data is! Map) throw const ApiException('Invalid login response');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> register({
    required String fullname,
    required String mobile,
    required String email,
    required String ward,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _post('/api/register', {
      'fullname': fullname,
      'mobile': mobile,
      'email': email,
      'ward': ward,
      'password': password,
      'confirm_password': confirmPassword,
    });
    if (data is! Map) throw const ApiException('Invalid registration response');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> requestPasswordReset({
    required String mobile,
    required String email,
  }) async {
    final data = await _post('/api/forgot_password', {'mobile': mobile, 'email': email});
    if (data is! Map) throw const ApiException('Invalid password reset response');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String mobile,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _post('/api/reset_password', {
      'mobile': mobile,
      'code': code,
      'password': password,
      'confirm_password': confirmPassword,
    });
    if (data is! Map) throw const ApiException('Invalid password reset response');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> submitComplaint({
    required String name,
    required String mobile,
    required String ward,
    required String category,
    required String description,
  }) async {
    final data = await _post('/api/submit_complaint', {
      'name': name,
      'mobile': mobile,
      'ward': ward,
      'category': category,
      'description': description,
    });
    if (data is! Map) throw const ApiException('Invalid complaint response');
    return Map<String, dynamic>.from(data);
  }

  static Future<List<Complaint>> getMyComplaints(String mobile) async {
    final data = await _get('/api/my_complaints/${Uri.encodeComponent(mobile)}');
    return _parseList(data, Complaint.fromJson);
  }

  static Future<List<Announcement>> getAnnouncements() async {
    return _parseList(await _get('/api/announcements'), Announcement.fromJson);
  }

  static Future<List<Program>> getPrograms() async {
    return _parseList(await _get('/api/programs'), Program.fromJson);
  }

  static Future<List<DownloadDocument>> getDownloads() async {
    return _parseList(await _get('/api/downloads'), DownloadDocument.fromJson);
  }

  static Future<List<Circular>> getCirculars() async {
    return _parseList(await _get('/api/circulars'), Circular.fromJson);
  }

  static Future<List<GalleryPhoto>> getGallery() async {
    return _parseList(await _get('/api/gallery'), GalleryPhoto.fromJson);
  }

  static Future<List<AppNotification>> getNotifications(String mobile) async {
    return _parseList(
      await _get('/api/notifications/${Uri.encodeComponent(mobile)}'),
      AppNotification.fromJson,
    );
  }

  static Future<Survey?> getSurvey() async {
    final data = await _get('/api/survey');
    if (data is! Map) throw const ApiException('Invalid survey response');
    final survey = data['survey'];
    if (survey is! Map) return null;
    final options = data['options'] is List ? data['options'] as List : const [];
    return Survey.fromJson(
      Map<String, dynamic>.from(survey),
      options.whereType<Map>().map(Map<String, dynamic>.from).toList(),
    );
  }

  static Future<Map<String, dynamic>> voteSurvey({
    required String mobile,
    required int optionId,
  }) async {
    final data = await _post('/api/survey', {
      'mobile': mobile,
      'option_id': optionId,
    });
    if (data is! Map) throw const ApiException('Invalid survey vote response');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String mobile,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final data = await _post('/api/change_password', {
      'mobile': mobile,
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
    if (data is! Map) throw const ApiException('Invalid password response');
    return Map<String, dynamic>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getWardMembers() async {
    final data = await _get('/api/ward_members');
    if (data is! List) throw const ApiException('Invalid ward member response');
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String mobile,
    required String fullname,
    required String email,
  }) async {
    final data = await _post('/api/update_profile', {
      'mobile': mobile,
      'fullname': fullname,
      'email': email,
    });
    if (data is! Map) throw const ApiException('Invalid profile response');
    return Map<String, dynamic>.from(data);
  }

  static List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) parser) {
    if (data is! List) throw const ApiException('Invalid list response');
    return data
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }
}