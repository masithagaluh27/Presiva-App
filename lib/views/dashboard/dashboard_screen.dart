// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const DashboardScreen({super.key, required this.apiService});
  static const String id = '/DashboardScreen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await widget.apiService.getProfile();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    await widget.apiService.logout();
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(apiService: widget.apiService),
      ),
      (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
    );
  }

  String _getGreetingMessage(String? jenisKelamin) {
    if (jenisKelamin == 'M') {
      return 'Selamat pagi gantengku';
    } else if (jenisKelamin == 'F') {
      return 'Selamat pagi cantikku';
    } else {
      return 'Selamat pagi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchUserProfile, // Refresh data
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _handleLogout, // Logout
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _currentUser == null
              ? const Center(
                child: Text(
                  'Tidak dapat memuat data pengguna. Silakan login kembali.',
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modified: Personalized greeting
                    Text(
                      '${_getGreetingMessage(_currentUser!.jenisKelamin)}, ${_currentUser!.name}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${_currentUser!.email}'),
                    Text(
                      'Jenis Kelamin: ${_currentUser!.jenisKelamin == 'M'
                          ? 'Laki-laki'
                          : _currentUser!.jenisKelamin == 'F'
                          ? 'Perempuan'
                          : 'Tidak disebutkan'}',
                    ), // Display full text for gender
                    Text('Batch ID: ${_currentUser!.batchId ?? "N/A"}'),
                    Text('Training ID: ${_currentUser!.trainingId ?? "N/A"}'),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(
                                    apiService: widget.apiService,
                                  ),
                            ),
                          );
                        },
                        child: const Text('Lihat & Edit Profil'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          final attendance = await widget.apiService.checkIn(
                            checkInLat: -6.2088, // Contoh koordinat
                            checkInLng: 106.8456,
                            checkInAddress: 'Jakarta, Indonesia',
                            status: 'hadir',
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          if (attendance != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Check-in berhasil!'),
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Check-in gagal!')),
                            );
                          }
                        },
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text('Check-in Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
