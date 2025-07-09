// lib/api/endpoints.dart
class Endpoint {
  static final String baseUrl = 'https://appabsensi.mobileprojp.com/api';

  // Endpoints yang sudah ada (termasuk login dan register)
  static final String register = '$baseUrl/register';
  static final String login = '$baseUrl/login';
  static final String getBatch = '$baseUrl/batches';
  static final String getTraining = '$baseUrl/trainings';
  static final String allHistoryAbsen = '$baseUrl/absen/history';
  static final String statAbsen = '$baseUrl/absen/stats';
  static final String profile = '$baseUrl/profile';
  static final String checkIn = '$baseUrl/absen/check-in';
  static final String checkOut = '$baseUrl/absen/check-out';
  static final String todayAbsen = '$baseUrl/absen/today';

  // Endpoint logout (ada di sini!)
  static final String logout = '$baseUrl/logout'; // <-- Ini dia!

  // Endpoints yang ditambahkan lainnya
  static final String updateProfile = '$baseUrl/profile/update';
  static final String refreshToken = '$baseUrl/refresh';
  static final String resetPassword = '$baseUrl/reset-password';

  // Dynamic Endpoints (yang membutuhkan ID, termasuk detail batch dan training!)
  static String getBatchDetail(int id) =>
      '$baseUrl/batches/$id'; // <-- Ini dia!
  static String getTrainingDetail(int id) =>
      '$baseUrl/trainings/$id'; // <-- Ini dia!
  static String deleteAttendance(int id) => '$baseUrl/absen/$id';
}
