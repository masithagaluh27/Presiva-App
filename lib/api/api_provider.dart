// lib/api/api_provider.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:presiva/Endpoint.dart';
import 'package:presiva/helper/preference_handler.dart';
import 'package:presiva/models/app_models.dart';

class ApiService {
  String? _token;

  ApiService({String? initialToken}) : _token = initialToken;

  void setToken(String token) {
    _token = token;
    print('Token diatur: $_token'); // Debugging: Konfirmasi token diatur
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
    required String jenisKelamin,
    String? profilePhoto,
    int? batchId, // Added batchId
    int? trainingId, // Added trainingId
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Endpoint.register),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password,
          'jenis_kelamin': jenisKelamin,
          if (profilePhoto != null) 'profile_photo': profilePhoto,
          if (batchId != null) 'batch_id': batchId, // Added batch_id to payload
          if (trainingId != null)
            'training_id': trainingId, // Added training_id to payload
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
    final url = Uri.parse(Endpoint.login);
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
    final url = Uri.parse(Endpoint.profile);
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
    final url = Uri.parse(Endpoint.logout);
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

  // MODIFIKASI: Mengembalikan Attendance, bukan Attendance? dan menangani 409
  Future<Attendance> checkIn({
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
    required String status,
    String? alasanIzin,
  }) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    final url = Uri.parse(Endpoint.checkIn);
    final payload = {
      'attendance_date': formattedDate,
      'check_in': formattedTime,
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

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Attendance.fromJson(responseData['data']);
      } else if (response.statusCode == 409) {
        // Server bilang sudah absen masuk, tapi berikan data absennya
        if (responseData['data'] != null) {
          print(
            'Info: Absen masuk sudah tercatat, memperbarui status dari respons 409.',
          );
          return Attendance.fromJson(responseData['data']);
        } else {
          // 409 tanpa data yang relevan, masih bisa dianggap error
          throw Exception(
            'Failed to check in (Conflict): ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        // Tangani kode status error lainnya
        throw Exception(
          'Failed to check in: ${response.statusCode} - ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error during check-in: $e');
      rethrow; // Melempar ulang exception untuk ditangani di layer UI
    }
  }

  // MODIFIKASI: Mengembalikan Attendance, bukan Attendance? dan menangani 409
  Future<Attendance> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutAddress,
  }) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    final url = Uri.parse(Endpoint.checkOut);
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(requireAuth: true),
        body: json.encode({
          'attendance_date': formattedDate,
          'check_out': formattedTime,
          'check_out_lat': checkOutLat.toString(),
          'check_out_lng': checkOutLng.toString(),
          'check_out_address': checkOutAddress,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return Attendance.fromJson(responseData['data']);
      } else if (response.statusCode == 409) {
        // Server bilang sudah absen keluar, tapi berikan data absennya
        if (responseData['data'] != null) {
          print(
            'Info: Absen keluar sudah tercatat, memperbarui status dari respons 409.',
          );
          return Attendance.fromJson(responseData['data']);
        } else {
          // 409 tanpa data yang relevan, masih bisa dianggap error
          throw Exception(
            'Failed to check out (Conflict): ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        // Tangani kode status error lainnya
        throw Exception(
          'Failed to check out: ${response.statusCode} - ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error during check-out: $e');
      rethrow; // Melempar ulang exception untuk ditangani di layer UI
    }
  }

  // MODIFIKASI: Menyesuaikan penanganan error agar lebih konsisten
  Future<Attendance?> getTodayAttendance() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final url = Uri.parse('${Endpoint.todayAbsen}?date=$formattedDate');
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
        return null; // Tidak ada data absen di key 'data' untuk 200 OK
      } else if (response.statusCode == 404) {
        print('Tidak ada data absensi untuk tanggal ini (404 Not Found).');
        return null; // Secara eksplisit mengembalikan null untuk 404, menandakan tidak ada catatan untuk hari ini
      } else {
        // Untuk status kode lainnya, anggap sebagai error dan lempar Exception
        final responseData = json.decode(
          response.body,
        ); // Parse untuk mendapatkan pesan jika ada
        throw Exception(
          'Failed to get today attendance: ${response.statusCode} - ${responseData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Error getting today attendance: $e');
      rethrow; // Melempar ulang exception untuk ditangani di layer UI
    }
  }

  Future<Map<String, dynamic>?> getAttendanceStats() async {
    final url = Uri.parse(Endpoint.statAbsen);
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
    final url = Uri.parse(Endpoint.getTraining);
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
    final url = Uri.parse(Endpoint.getBatch);
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
    final url = Uri.parse(Endpoint.getBatchDetail(batchId));
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
    final url = Uri.parse(Endpoint.getTrainingDetail(trainingId));
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
    final url = Uri.parse(Endpoint.resetPassword);
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
    final url = Uri.parse(Endpoint.allHistoryAbsen);
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

  // Metode updateProfile yang diperbarui
  Future<User?> updateProfile({
    required String name,
    required String email,
    String? profilePhoto, // <-- Parameter ini ditambahkan
  }) async {
    final url = Uri.parse(Endpoint.updateProfile);
    try {
      final Map<String, dynamic> bodyData = {'name': name, 'email': email};

      if (profilePhoto != null) {
        bodyData['profile_photo'] =
            profilePhoto; // <-- Menambahkan foto ke body
      }

      final response = await http.put(
        url,
        headers: _getHeaders(requireAuth: true),
        body: json.encode(
          bodyData,
        ), // Menggunakan bodyData yang sudah termasuk foto
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
    final url = Uri.parse(Endpoint.deleteAttendance(attendanceId));
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
