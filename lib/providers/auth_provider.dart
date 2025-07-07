// // lib/providers/auth_provider.dart
// import 'package:flutter/material.dart';
// import 'package:presiva/api/api_provider.dart';
// import 'package:presiva/models/app_models.dart';
// import 'package:presiva/helper/preference_handler.dart';

// enum AuthStatus {
//   uninitialized,
//   authenticated,
//   unauthenticated,
//   authenticating,
//   registering,
// }

// class AuthProvider extends ChangeNotifier {
//   final ApiService _apiService;
//   AuthStatus _status = AuthStatus.uninitialized;
//   User? _user;
//   String? _errorMessage;

//   AuthStatus get status => _status;
//   User? get user => _user;
//   String? get errorMessage => _errorMessage;
//   bool get isAuthenticated => _status == AuthStatus.authenticated;

//   AuthProvider(this._apiService) {
//     _checkAuthStatus();
//   }

//   Future<void> _checkAuthStatus() async {
//     final token = PreferenceHandler.getAuthToken();
//     if (token != null && token.isNotEmpty) {
//       _apiService.setToken(token); // Set token di ApiService
//       _user = await _apiService.getProfile(); // Coba ambil profil
//       if (_user != null) {
//         _status = AuthStatus.authenticated;
//       } else {
//         // Token mungkin tidak valid/expired, hapus
//         await PreferenceHandler.removeAuthToken();
//         _status = AuthStatus.unauthenticated;
//       }
//     } else {
//       _status = AuthStatus.unauthenticated;
//     }
//     notifyListeners();
//   }

//   Future<bool> login(String email, String password) async {
//     _status = AuthStatus.authenticating;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final token = await _apiService.login(email: email, password: password);
//       if (token != null) {
//         _apiService.setToken(token);
//         _user = await _apiService.getProfile();
//         if (_user != null) {
//           _status = AuthStatus.authenticated;
//           notifyListeners();
//           return true;
//         } else {
//           _errorMessage = 'Failed to fetch user profile after login.';
//           _status = AuthStatus.unauthenticated;
//           notifyListeners();
//           return false;
//         }
//       } else {
//         _errorMessage = 'Invalid email or password.';
//         _status = AuthStatus.unauthenticated;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Login failed: ${e.toString()}';
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> register({
//     required String name,
//     required String email,
//     required String password,
//     required int batchId,
//     required int trainingId,
//   }) async {
//     _status = AuthStatus.registering;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final newUser = await _apiService.register(
//         name: name,
//         email: email,
//         password: password,
//         batchId: batchId,
//         trainingId: trainingId,
//       );
//       if (newUser != null) {
//         // Setelah register, bisa langsung login atau arahkan ke halaman login
//         _status = AuthStatus.unauthenticated; // Kembali ke status siap login
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = 'Registration failed.';
//         _status = AuthStatus.unauthenticated;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Registration failed: ${e.toString()}';
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     await _apiService
//         .logout(); // Call API to revoke token on server if applicable
//     await PreferenceHandler.removeAuthToken(); // Remove token from local storage
//     _apiService
//         .clearToken(); // Assuming you have a method in ApiService to clear the token
//     _user = null;
//     _status = AuthStatus.unauthenticated;
//     notifyListeners();
//   }

//   Future<bool> updateProfile({
//     required String name,
//     required String email,
//   }) async {
//     if (_user == null) return false;
//     try {
//       final updatedUser = await _apiService.updateProfile(
//         name: name,
//         email: email,
//       );
//       if (updatedUser != null) {
//         _user = updatedUser;
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       _errorMessage = 'Failed to update profile: ${e.toString()}';
//       notifyListeners();
//       return false;
//     }
//   }
// }
