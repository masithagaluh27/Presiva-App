// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/profile/editprofile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({super.key, required this.apiService});
  static const String id = '/ProfileScreen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fungsi untuk mengambil data profil dari API
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
        _errorMessage = 'Gagal memuat profil: $e';
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));

      // Contoh penanganan error 401 (Unauthorized) jika token kedaluwarsa
      if (e.toString().contains('401')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(apiService: widget.apiService),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  // Fungsi untuk menangani logout
  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.apiService.logout();
      if (!mounted) return;
      // Redirect ke layar login dan hapus semua rute sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(apiService: widget.apiService),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  // Widget helper untuk membuat ubin opsi profil yang bisa diklik
  Widget _buildProfileOptionTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // Widget helper untuk menampilkan detail info
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
              : _currentUser == null
              ? const Center(
                child: Text(
                  'Tidak dapat memuat data profil. Silakan coba lagi.',
                ),
              )
              : RefreshIndicator(
                // Menambahkan RefreshIndicator untuk pull-to-refresh
                onRefresh: _fetchUserProfile,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Memungkinkan pull to refresh bahkan jika konten kecil
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Bagian Foto Profil, Nama, dan Peran
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[200],
                              // Menampilkan foto dari URL jika tersedia, jika tidak tampilkan ikon
                              backgroundImage:
                                  _currentUser!.profilePhotoUrl != null &&
                                          _currentUser!
                                              .profilePhotoUrl!
                                              .isNotEmpty
                                      ? NetworkImage(
                                        _currentUser!.profilePhotoUrl!,
                                      )
                                      : null,
                              child:
                                  _currentUser!.profilePhotoUrl == null ||
                                          _currentUser!.profilePhotoUrl!.isEmpty
                                      ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Theme.of(context).primaryColor,
                                      )
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentUser!.name,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              // Contoh peran berdasarkan batchId atau trainingId
                              'Peserta Batch ${_currentUser!.batchId ?? "N/A"}',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bagian Detail Akun
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Detail Akun',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInfoTile('Email', _currentUser!.email, Icons.email),
                      _buildInfoTile(
                        'Jenis Kelamin',
                        _currentUser!.jenisKelamin == 'M'
                            ? 'Laki-laki'
                            : (_currentUser!.jenisKelamin == 'F'
                                ? 'Perempuan'
                                : 'Tidak disebutkan'),
                        Icons.person_outline,
                      ),
                      _buildInfoTile(
                        'Batch ID',
                        _currentUser!.batchId?.toString() ?? 'N/A',
                        Icons.group,
                      ),
                      _buildInfoTile(
                        'Training ID',
                        _currentUser!.trainingId?.toString() ?? 'N/A',
                        Icons.school,
                      ),
                      const SizedBox(height: 24),

                      // Daftar Opsi (Edit Profil, Pengaturan Akun, Statistik Presensi)
                      _buildProfileOptionTile('Edit Profil', Icons.edit, () {
                        // Navigasi ke layar edit profil yang baru
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfileScreen(
                                  apiService: widget.apiService,
                                  currentUser: _currentUser!,
                                  onProfileUpdated:
                                      _fetchUserProfile, // Callback untuk me-refresh data setelah edit
                                ),
                          ),
                        );
                      }),
                      _buildProfileOptionTile(
                        'Pengaturan Akun',
                        Icons.settings,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navigasi ke Pengaturan Akun (belum diimplementasi)',
                              ),
                            ),
                          );
                        },
                      ),
                      _buildProfileOptionTile(
                        'Statistik Presensi',
                        Icons.bar_chart,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navigasi ke Statistik Presensi (belum diimplementasi)',
                              ),
                            ),
                          );
                        },
                      ),

                      // Opsi "Invites Friend" dihapus sesuai permintaan
                      const SizedBox(height: 24),
                      // Tombol Logout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // Warna merah untuk tombol logout
                            minimumSize: const Size(
                              double.infinity,
                              50,
                            ), // Tombol lebar penuh
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    // TextEditingController _nameController dan _emailController telah dipindahkan ke EditProfileScreen
    super.dispose();
  }
}
