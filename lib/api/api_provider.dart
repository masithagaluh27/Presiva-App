import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:presiva/helper/preference_handler.dart';
import 'package:presiva/models/app_models.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl, String? initialToken})
    : _token = initialToken;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders({bool requireAuth = false}) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (requireAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // --- Authentication Endpoints ---

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required int batchId,
    required int trainingId,
  }) async {
    final url = Uri.parse('$baseUrl/api/register');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'batch_id': batchId,
          'training_id': trainingId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['data']);
      } else {
        print('Failed to register: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String? receivedToken = responseData['data']['token'];
        if (receivedToken != null) {
          await PreferenceHandler.saveAuthToken(receivedToken);
          _token = receivedToken;
        }
        return receivedToken;
      } else {
        print('Failed to login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<User?> getProfile() async {
    final url = Uri.parse('$baseUrl/api/profile');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['data']);
      } else {
        print(
          'Failed to get profile: ${response.statusCode} - ${response.body}',
        );
        if (response.statusCode == 401) {
          await PreferenceHandler.removeAuthToken();
          _token = null;
        }
        return null;
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/api/logout');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        await PreferenceHandler.removeAuthToken();
        _token = null;
        print('Successfully logged out.');
      } else {
        print('Failed to logout: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // --- Attendance Endpoints ---

  Future<Attendance?> checkIn({
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
    required String status,
    String? alasanIzin,
  }) async {
    final url = Uri.parse('$baseUrl/api/absen/check-in');
    final payload = {
      'check_in_lat': checkInLat.toString(),
      'check_in_lng': checkInLng.toString(),
      'check_in_address': checkInAddress,
      'status': status,
    };
    if (alasanIzin != null) {
      payload['alasan_izin'] = alasanIzin;
    }

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(requireAuth: true),
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Attendance.fromJson(responseData['data']);
      } else {
        print('Failed to check in: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during check-in: $e');
      return null;
    }
  }

  Future<Attendance?> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutAddress,
  }) async {
    final url = Uri.parse('$baseUrl/api/absen/check-out');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(requireAuth: true),
        body: json.encode({
          'check_out_lat': checkOutLat.toString(),
          'check_out_lng': checkOutLng.toString(),
          'check_out_address': checkOutAddress,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Attendance.fromJson(responseData['data']);
      } else {
        print('Failed to check out: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during check-out: $e');
      return null;
    }
  }

  Future<Attendance?> getTodayAttendance() async {
    final url = Uri.parse('$baseUrl/api/absen/today');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return Attendance.fromJson(responseData['data']);
        }
        return null;
      } else {
        print(
          'Failed to get today attendance: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting today attendance: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAttendanceStats() async {
    final url = Uri.parse('$baseUrl/api/absen/stats');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print(
          'Failed to get attendance stats: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting attendance stats: $e');
      return null;
    }
  }

  Future<List<Batch>?> listAllBatches() async {
    final url = Uri.parse('$baseUrl/api/batches');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => Batch.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return null;
      } else {
        print(
          'Failed to list batches: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error listing batches: $e');
      return null;
    }
  }

  Future<Training?> getTrainingDetail(int trainingId) async {
    final url = Uri.parse('$baseUrl/api/trainings/$trainingId');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Training.fromJson(responseData['data']);
      } else {
        print(
          'Failed to get training detail: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting training detail: $e');
      return null;
    }
  }

  // --- Placeholder Endpoints (Tidak ada di Postman Anda, diasumsikan dari requirements) ---

  /// Placeholder: Mengambil riwayat absen. API ini tidak ada di Postman yang Anda berikan.
  /// Asumsi endpoint: GET /api/absen/history
  Future<List<Attendance>?> getAttendanceHistory() async {
    final url = Uri.parse('$baseUrl/api/absen/history');
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return []; // Mengembalikan list kosong jika 'data' bukan list
      } else {
        print(
          'Failed to get attendance history: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting attendance history: $e');
      return null;
    }
  }

  /// Placeholder: Mengupdate profil pengguna (nama/email). API ini tidak ada di Postman.
  /// Asumsi endpoint: PUT /api/profile/update
  Future<User?> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/api/profile/update');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(requireAuth: true),
        body: json.encode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['data']);
      } else {
        print(
          'Failed to update profile: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  /// Placeholder: Menghapus data absen berdasarkan ID. API ini tidak ada di Postman.
  /// Asumsi endpoint: DELETE /api/absen/{id}
  Future<bool> deleteAttendance(int attendanceId) async {
    final url = Uri.parse('$baseUrl/api/absen/$attendanceId');
    try {
      final response = await http.delete(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        print('Attendance with ID $attendanceId deleted successfully.');
        return true;
      } else {
        print(
          'Failed to delete attendance: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error deleting attendance: $e');
      return false;
    }
  }
}
