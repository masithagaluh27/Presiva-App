// main.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Paket Provider tidak digunakan di sini untuk saat ini

import 'package:presiva/api/api_service.dart';
// import 'package:presiva/providers/auth_provider.dart'; // Tidak digunakan di sini untuk saat ini
// import 'package:presiva/providers/attendance_provider.dart'; // Tidak digunakan di sini untuk saat ini
import 'package:presiva/views/auth/login_screen.dart';

void main() async {
  // Pastikan inisialisasi Flutter sudah selesai sebelum menggunakan plugin
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi ApiService dengan base URL Anda.
  // Ganti 'YOUR_API_BASE_URL' dengan URL API aktual Anda!
  final ApiService apiService = ApiService(baseUrl: 'YOUR_API_BASE_URL');

  // PENTING: Jika Anda menggunakan shared_preferences secara sinkron di PreferenceHandler.getAuthToken(),
  // Anda harus memastikan SharedPreferences diinisialisasi secara async di sini:
  // await SharedPreferences.getInstance(); // Contoh, tapi ini akan dihandle oleh PreferenceHandler internal jika metode getAuthToken() dibuat async

  runApp(
    // Karena Anda ingin menghindari Provider untuk saat ini,
    // kita akan langsung menjalankan MyApp dan meneruskan ApiService.
    MyApp(apiService: apiService),

    // Jika nanti Anda ingin menggunakan Provider, Anda bisa mengganti ini dengan:
    /*
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(apiService),
        ),
        // Tambahkan provider lain di sini (misal AttendanceProvider)
        // ChangeNotifierProvider(
        //   create: (context) => AttendanceProvider(apiService),
        // ),
      ],
      child: MyApp(apiService: apiService), // Atau MyApp tanpa passing apiService jika Provider sudah diaktifkan di atasnya
    ),
    */
  );
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Halaman awal aplikasi Anda adalah SplashScreen
      home: SplashScreen(apiService: apiService),
    );
  }
}
