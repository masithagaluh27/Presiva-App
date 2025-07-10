// lib/main.dart
import 'package:flutter/material.dart';
import 'package:presiva/splash_screen.dart';
import 'package:presiva/utils/app_color.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/auth/register_screen.dart';
import 'package:presiva/views/dashboard/dashboard_screen.dart';
import 'package:presiva/views/auth/profile_screen.dart';

import 'api/api_provider.dart';
import 'helper/preference_handler.dart'; // Pastikan ini di-import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init(); // Inisialisasi PreferenceHandler

  // Dapatkan token yang tersimpan di preferensi jika ada
  final String? initialToken = PreferenceHandler.getAuthToken();

  // Inisialisasi ApiService tanpa baseUrl di konstruktor
  // ApiService akan menggunakan baseUrl dari Endpoint secara internal
  final apiService = ApiService(initialToken: initialToken);

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme, // Tema yang digunakan
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(apiService: apiService),
        LoginScreen.id: (context) => LoginScreen(apiService: apiService),
        RegisterScreen.id: (context) => RegisterScreen(apiService: apiService),
        DashboardScreen.id:
            (context) => DashboardScreen(apiService: apiService),
        ProfileScreen.id: (context) => ProfileScreen(apiService: apiService),
      },
    );
  }
}
