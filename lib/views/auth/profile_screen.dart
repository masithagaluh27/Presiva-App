// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart'; // Pastikan file ini berisi definisi kelas User, Batch, dan Training
import 'package:presiva/views/auth/editprofile_screen.dart';
import 'package:presiva/views/auth/login_screen.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ), // Sudut lebih kecil dari sebelumnya
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18.0, // Padding dikurangi sedikit
          vertical: 6.0, // Padding dikurangi sedikit
        ),
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24, // Ukuran ikon diperkecil
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500, // Ketebalan dikurangi sedikit
            fontSize: 15, // Ukuran font dikurangi
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18, // Ukuran ikon diperkecil
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  // Widget helper untuk menampilkan detail info
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0, // Padding disesuaikan
        vertical: 6.0, // Padding disesuaikan
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20, // Ukuran ikon diperkecil
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12), // Jarak dikurangi
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    // Menggunakan bodyMedium atau bodySmall
                    fontWeight: FontWeight.w400, // Ketebalan dikurangi
                    color: Colors.black87,
                  ),
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
        elevation: 0,
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
                onRefresh: _fetchUserProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header Profil: Background berwarna primer, foto profil besar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                        ), // Padding vertikal diperkecil
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(
                              25,
                            ), // Radius diperkecil
                            bottomRight: Radius.circular(
                              25,
                            ), // Radius diperkecil
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius:
                                  50, // Ukuran CircleAvatar utama diperkecil
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius:
                                    47, // Ukuran foto profil di dalam border diperkecil
                                backgroundColor: Colors.grey[200],
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
                                            _currentUser!
                                                .profilePhotoUrl!
                                                .isEmpty
                                        ? Icon(
                                          Icons.person,
                                          size: 50, // Ukuran ikon diperkecil
                                          color: Theme.of(context).primaryColor,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 12), // Jarak diperkecil
                            Text(
                              _currentUser!.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                // Menggunakan titleLarge atau headlineSmall
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4), // Jarak diperkecil
                            Text(
                              'Peserta Batch ${_currentUser!.batch?.batchKe ?? "N/A"}', // Menggunakan batch?.batchKe
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                // Menggunakan bodyMedium
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Jarak diperkecil
                      // Bagian Detail Akun
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Detail Akun',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              // Menggunakan titleMedium
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Jarak diperkecil
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        elevation: 2, // Elevasi dikurangi sedikit
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Radius diperkecil
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ), // Padding internal card diperkecil
                          child: Column(
                            children: [
                              _buildInfoTile(
                                'Email',
                                _currentUser!.email,
                                Icons.email,
                              ),
                              _buildInfoTile(
                                'Jenis Kelamin',
                                _currentUser!.jenisKelamin == 'L'
                                    ? 'Laki-laki'
                                    : (_currentUser!.jenisKelamin == 'P'
                                        ? 'Perempuan'
                                        : 'Tidak disebutkan'),
                                Icons.person_outline,
                              ),
                              _buildInfoTile(
                                'Batch', // Mengganti 'Batch ID' menjadi 'Batch'
                                _currentUser!.batch?.batchKe ??
                                    'N/A', // Menggunakan batch?.batchKe
                                Icons.group,
                              ),
                              // PERBAIKAN: Mengakses properti 'title' dari objek Training
                              _buildInfoTile(
                                'Training', // Mengganti 'Training ID' menjadi 'Training'
                                _currentUser!.training?.title ??
                                    'N/A', // Menggunakan training?.title
                                Icons.school,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Jarak diperkecil
                      // Daftar Opsi (Edit Profil, Reset Password, Statistik Presensi)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Opsi Lainnya',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              // Menggunakan titleMedium
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Jarak diperkecil
                      _buildProfileOptionTile('Edit Profil', Icons.edit, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfileScreen(
                                  apiService: widget.apiService,
                                  currentUser: _currentUser!,
                                  onProfileUpdated: _fetchUserProfile,
                                ),
                          ),
                        );
                      }),
                      _buildProfileOptionTile(
                        'Reset Password',
                        Icons.lock_reset_outlined,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navigasi ke Reset Password (belum diimplementasi)',
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

                      const SizedBox(
                        height: 24,
                      ), // Spasi sebelum tombol logout diperkecil
                      // Tombol Logout
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ), // Ukuran font diperkecil
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(
                              double.infinity,
                              50,
                            ), // Tinggi tombol diperkecil
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Radius diperkecil
                            ),
                            elevation: 3, // Elevasi dikurangi
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ), // Spasi di bagian bawah diperkecil
                    ],
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
