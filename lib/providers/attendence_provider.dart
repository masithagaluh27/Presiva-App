// // lib/providers/attendance_provider.dart
// import 'package:flutter/material.dart';
// import 'package:presiva/api/api_provider.dart';
// import 'package:presiva/models/app_models.dart';

// class AttendanceProvider extends ChangeNotifier {
//   final ApiService _apiService;

//   Attendance?
//   _todayAttendance; // Change from AttendanceProvider? to Attendance?
//   Map<String, dynamic>? _attendanceStats;
//   List<Attendance> _attendanceHistory =
//       []; // Change from List<AttendanceProvider> to List<Attendance>
//   List<Batch> _batches = [];
//   final List<Training> _trainings = [];

//   bool _isLoadingTodayAttendance = false;
//   bool _isLoadingStats = false;
//   bool _isLoadingHistory = false;
//   bool _isLoadingBatches = false;
//   bool _isLoadingTrainings = false;

//   String? _errorMessage;

//   Attendance? get todayAttendance => _todayAttendance;
//   Map<String, dynamic>? get attendanceStats => _attendanceStats;
//   List<Attendance> get attendanceHistory => _attendanceHistory;
//   List<Batch> get batches => _batches;
//   List<Training> get trainings => _trainings;

//   bool get isLoadingTodayAttendance => _isLoadingTodayAttendance;
//   bool get isLoadingStats => _isLoadingStats;
//   bool get isLoadingHistory => _isLoadingHistory;
//   bool get isLoadingBatches => _isLoadingBatches;
//   bool get isLoadingTrainings => _isLoadingTrainings;
//   String? get errorMessage => _errorMessage;

//   AttendanceProvider(this._apiService);

//   Future<void> fetchTodayAttendance() async {
//     _isLoadingTodayAttendance = true;
//     _errorMessage = null;
//     notifyListeners();
//     _todayAttendance = await _apiService.getTodayAttendance();
//     _isLoadingTodayAttendance = false;
//     if (_todayAttendance == null) {
//       _errorMessage = 'Failed to load today\'s attendance.';
//     }
//     notifyListeners();
//   }

//   Future<void> fetchAttendanceStats() async {
//     _isLoadingStats = true;
//     _errorMessage = null;
//     notifyListeners();
//     _attendanceStats = await _apiService.getAttendanceStats();
//     _isLoadingStats = false;
//     if (_attendanceStats == null) {
//       _errorMessage = 'Failed to load attendance statistics.';
//     }
//     notifyListeners();
//   }

//   Future<void> fetchAttendanceHistory() async {
//     _isLoadingHistory = true;
//     _errorMessage = null;
//     notifyListeners();
//     _attendanceHistory = (await _apiService.getAttendanceHistory()) ?? [];
//     _isLoadingHistory = false;
//     if (_attendanceHistory.isEmpty && _errorMessage == null) {
//       _errorMessage = 'No attendance history found.';
//     }
//     notifyListeners();
//   }

//   Future<void> fetchBatches() async {
//     _isLoadingBatches = true;
//     _errorMessage = null;
//     notifyListeners();
//     _batches = (await _apiService.listAllBatches()) ?? [];
//     _isLoadingBatches = false;
//     if (_batches.isEmpty && _errorMessage == null) {
//       _errorMessage = 'No batches found.';
//     }
//     notifyListeners();
//   }

//   Future<void> fetchTrainingDetail(int trainingId) async {
//     _isLoadingTrainings = true;
//     _errorMessage = null;
//     notifyListeners();
//     Training? training = await _apiService.getTrainingDetail(trainingId);
//     _isLoadingTrainings = false;
//     if (training != null) {
//       // Logic untuk menyimpan detail training yang diambil
//       // Misalnya, jika hanya satu training yang diambil pada satu waktu:
//       // _trainings.clear();
//       // _trainings.add(training);
//     } else {
//       _errorMessage = 'Failed to load training details.';
//     }
//     notifyListeners();
//   }

//   Future<bool> performCheckIn({
//     required double lat,
//     required double lng,
//     required String address,
//     required String status,
//     String? reason,
//   }) async {
//     _isLoadingTodayAttendance = true; // Set loading state for check-in
//     _errorMessage = null;
//     notifyListeners();

//     final result = await _apiService.checkIn(
//       checkInLat: lat,
//       checkInLng: lng,
//       checkInAddress: address,
//       status: status,
//       alasanIzin: reason,
//     );
//     _isLoadingTodayAttendance = false;
//     if (result != null) {
//       _todayAttendance = result;
//       notifyListeners();
//       await fetchAttendanceStats(); // Refresh stats after check-in
//       return true;
//     } else {
//       _errorMessage = 'Check-in failed.';
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> performCheckOut({
//     required double lat,
//     required double lng,
//     required String address,
//   }) async {
//     _isLoadingTodayAttendance = true; // Set loading state for check-out
//     _errorMessage = null;
//     notifyListeners();

//     final result = await _apiService.checkOut(
//       checkOutLat: lat,
//       checkOutLng: lng,
//       checkOutAddress: address,
//     );
//     _isLoadingTodayAttendance = false;
//     if (result != null) {
//       _todayAttendance = result;
//       notifyListeners();
//       await fetchAttendanceStats(); // Refresh stats after check-out
//       return true;
//     } else {
//       _errorMessage = 'Check-out failed.';
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> deleteHistoryEntry(int attendanceId) async {
//     _isLoadingHistory = true;
//     _errorMessage = null;
//     notifyListeners();
//     final success = await _apiService.deleteAttendance(attendanceId);
//     _isLoadingHistory = false;
//     if (success) {
//       await fetchAttendanceHistory(); // Refresh list after deletion
//     } else {
//       _errorMessage = 'Failed to delete attendance record.';
//     }
//     notifyListeners();
//     return success;
//   }
// }
