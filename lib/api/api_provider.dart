// lib/api/api_provider.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:presiva/helper/preference_handler.dart';
import 'package:presiva/Endpoint.dart';
import 'package:presiva/models/app_models.dart';

class ApiService {
  // baseUrl tidak lagi diperlukan di sini karena sudah ada di kelas Endpoint
  String? _token;

  // Constructor tanpa baseUrl
  ApiService({String? initialToken}) : _token = initialToken;

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
    required String jenisKelamin,
    required int trainingId,
    String? profilePhoto,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.register), // <--- Menggunakan Endpoint.register
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
          'batch_id': batchId,
          'jenis_kelamin': jenisKelamin,
          'training_id': trainingId,
          if (profilePhoto != null) 'profile_photo': profilePhoto,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['data'] != null &&
            responseData['data']['user'] != null) {
          return User.fromJson(responseData['data']['user']);
        } else if (responseData['user'] != null) {
          return User.fromJson(responseData['user']);
        } else {
          print(
            'Gagal registrasi: Struktur respons tidak sesuai - ${response.body}',
          );
          return null;
        }
      } else {
        print('Gagal registrasi: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan saat registrasi: $e');
      return null;
    }
  }

  Future<AuthResponse?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login); // <--- Menggunakan Endpoint.login
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Login success (200 OK) Response Body: $responseData');

        if (responseData['data'] != null) {
          final authResponse = AuthResponse.fromJson(responseData['data']);
          await PreferenceHandler.saveAuthToken(authResponse.accessToken);
          _token = authResponse.accessToken;
          return authResponse;
        } else {
          print('Login failed: "data" key is missing or null in response.');
          return null;
        }
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
    final url = Uri.parse(
      Endpoint.profile,
    ); // <--- Menggunakan Endpoint.profile
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
    final url = Uri.parse(Endpoint.logout); // <--- Menggunakan Endpoint.logout
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

  // Future<AuthResponse?> refreshToken() async {
  //   final url = Uri.parse(Endpoint.refresh); // <--- Menggunakan Endpoint.refresh
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: _getHeaders(requireAuth: true),
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       final authResponse = AuthResponse.fromJson(responseData['data']);
  //       await PreferenceHandler.saveAuthToken(authResponse.accessToken);
  //       _token = authResponse.accessToken;
  //       return authResponse;
  //     } else {
  //       print(
  //           'Failed to refresh token: ${response.statusCode} - ${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error during token refresh: $e');
  //     return null;
  //   }
  // }

  // --- Attendance Endpoints ---

  Future<Attendance?> checkIn({
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
    required String status,
    String? alasanIzin,
  }) async {
    final url = Uri.parse(
      Endpoint.checkIn,
    ); // <--- Menggunakan Endpoint.checkIn
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
    final url = Uri.parse(
      Endpoint.checkOut,
    ); // <--- Menggunakan Endpoint.checkOut
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
    final url = Uri.parse(
      Endpoint.todayAbsen,
    ); // <--- Menggunakan Endpoint.todayAbsen
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
    final url = Uri.parse(
      Endpoint.statAbsen,
    ); // <--- Menggunakan Endpoint.statAbsen
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

  // --- Training & Batch Endpoints ---

  Future<List<Training>> getTrainings() async {
    final url = Uri.parse(
      Endpoint.getTraining,
    ); // <--- Menggunakan Endpoint.getTraining
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: false),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => Training.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        print(
          'Failed to get trainings: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getting trainings: $e');
      return [];
    }
  }

  Future<List<Batch>> getBatches() async {
    final url = Uri.parse(
      Endpoint.getBatch,
    ); // <--- Menggunakan Endpoint.getBatch
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: false),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((e) => Batch.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        print(
          'Failed to get batches: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error getting batches: $e');
      return [];
    }
  }

  Future<Batch?> getBatchDetail(int batchId) async {
    final url = Uri.parse(
      Endpoint.getBatchDetail(batchId),
    ); // <--- Menggunakan Endpoint.batchDetail
    try {
      final response = await http.get(
        url,
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Batch.fromJson(responseData['data']);
      } else {
        print(
          'Failed to get batch detail: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting batch detail: $e');
      return null;
    }
  }

  Future<Training?> getTrainingDetail(int trainingId) async {
    final url = Uri.parse(
      Endpoint.getTrainingDetail(trainingId),
    ); // <--- Menggunakan Endpoint.trainingDetail
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

  // --- Password Reset Endpoints ---

  Future<String?> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse(
      Endpoint.resetPassword,
    ); // <--- Menggunakan Endpoint.resetPassword
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'email': email,
          'otp': otp,
          'password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['message'];
      } else {
        print(
          'Failed to reset password: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error during password reset: $e');
      return null;
    }
  }

  // --- Placeholder Endpoints ---

  Future<List<Attendance>?> getAttendanceHistory() async {
    final url = Uri.parse(
      Endpoint.allHistoryAbsen,
    ); // <--- Menggunakan Endpoint.allHistoryAbsen
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
        return [];
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

  Future<User?> updateProfile({
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(
      Endpoint.updateProfile,
    ); // <--- Menggunakan Endpoint.updateProfile
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

  Future<bool> deleteAttendance(int attendanceId) async {
    final url = Uri.parse(
      Endpoint.deleteAttendance(attendanceId),
    ); // <--- Menggunakan Endpoint.deleteAttendance
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
