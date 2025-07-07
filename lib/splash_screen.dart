// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/helper/preference_handler.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final ApiService apiService;

  const SplashScreen({super.key, required this.apiService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu sebentar untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));

    final token =
        PreferenceHandler.getAuthToken(); // Mendapatkan token secara sync (hati-hati, baca catatan di PreferenceHandler)

    if (token != null && token.isNotEmpty) {
      widget.apiService.setToken(token); // Set token di ApiService
      // Coba ambil profil untuk memverifikasi token
      final user = await widget.apiService.getProfile();
      if (user != null) {
        // Token valid, arahkan ke dashboard
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => DashboardScreen(apiService: widget.apiService),
          ),
        );
      } else {
        // Token tidak valid/expired, hapus dan arahkan ke login
        await PreferenceHandler.removeAuthToken();
        widget.apiService.clearToken();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(apiService: widget.apiService),
          ),
        );
      }
    } else {
      // Tidak ada token, arahkan ke login
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(apiService: widget.apiService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.app_registration, // Contoh ikon aplikasi
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Presensi App',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Indikator loading
          ],
        ),
      ),
    );
  }
}
