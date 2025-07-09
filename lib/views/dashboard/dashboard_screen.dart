import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Tambahkan ini
import 'package:geocoding/geocoding.dart'; // Tambahkan ini untuk reverse geocoding
import 'package:intl/intl.dart'; // Tambahkan ini untuk format tanggal/waktu

import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/profile/profile_screen.dart';
import 'package:presiva/views/history/history_screen.dart'; // Pastikan ini di-import

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const DashboardScreen({super.key, required this.apiService});
  static const String id = '/DashboardScreen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _currentUser;
  Attendance? _todayAttendance; // Untuk menyimpan data presensi hari ini
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 0; // Untuk BottomNavigationBar

  // Daftar halaman untuk BottomNavigationBar
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Panggil fungsi untuk mengambil data user dan presensi hari ini
    // Inisialisasi _pages di sini agar tidak null saat pertama kali build
    _pages = [
      _HomePage(
        apiService: widget.apiService,
        fetchUserData: _fetchUserData,
      ), // _HomePage akan di-rebuild dengan data terbaru
      HistoryScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ];
  }

  // Gabungkan pengambilan profil dan presensi hari ini
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await widget.apiService.getProfile();
      final todayAbsen = await widget.apiService.getTodayAttendance();
      setState(() {
        _currentUser = user;
        _todayAttendance = todayAbsen;
        _isLoading = false;
      });
      // Setelah data diambil, _pages tidak perlu diinisialisasi ulang di sini
      // karena _HomePage akan menerima data terbaru melalui widget.currentUser, dll.
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
      // Jika terjadi 401 Unauthorized, mungkin arahkan ke Login
      if (e.toString().contains('401')) {
        // Contoh penanganan sederhana untuk 401
        // Arahkan ke LoginScreen dan hapus rute sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(apiService: widget.apiService),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _pages akan selalu merujuk ke instance yang sama,
    // namun _HomePage akan menggunakan data _currentUser dan _todayAttendance
    // yang diperbarui dari _DashboardScreenState
    if (_selectedIndex == 0) {
      // Hanya update _HomePage jika tab home yang aktif
      _pages[0] = _HomePage(
        apiService: widget.apiService,
        currentUser: _currentUser,
        todayAttendance: _todayAttendance,
        fetchUserData: _fetchUserData,
      );
    }

    return Scaffold(
      // Tidak ada AppBar sesuai desain UI
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
              : _pages[_selectedIndex], // Tampilkan halaman yang dipilih

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Theme.of(context).primaryColor, // Warna ikon/teks yang dipilih
        unselectedItemColor: Colors.grey, // Warna ikon/teks yang tidak dipilih
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget terpisah untuk konten tab Home
class _HomePage extends StatefulWidget {
  final ApiService apiService;
  final User? currentUser;
  final Attendance? todayAttendance;
  final VoidCallback
  fetchUserData; // Callback untuk me-refresh data dari DashboardScreen

  const _HomePage({
    required this.apiService,
    this.currentUser,
    this.todayAttendance,
    required this.fetchUserData,
  });

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  bool _isPerformingAction =
      false; // Untuk indikator loading pada tombol check-in/out

  @override
  void initState() {
    super.initState();
    // Tidak perlu memanggil _fetchUserProfile di sini karena data sudah di-pass dari parent
  }

  String _getGreetingMessage(String? jenisKelamin) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Selamat Siang';
    } else if (hour >= 18 && hour < 22) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    if (jenisKelamin == 'M') {
      // Asumsi 'M' untuk Laki-laki
      return '$greeting gantengku';
    } else if (jenisKelamin == 'F') {
      // Asumsi 'F' untuk Perempuan
      return '$greeting cantikku';
    } else {
      return greeting;
    }
  }

  Future<void> _getCurrentLocationAndCheck(
    Function(Position, String) apiCall,
  ) async {
    setState(() {
      _isPerformingAction = true;
    });
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String address =
          placemarks.isNotEmpty
              ? "${placemarks.first.thoroughfare ?? ''}, ${placemarks.first.subLocality ?? ''}, ${placemarks.first.locality ?? ''}, ${placemarks.first.administrativeArea ?? ''}, ${placemarks.first.country ?? ''}"
              : 'Lokasi tidak diketahui';

      await apiCall(
        position,
        address,
      ); // Panggil fungsi API yang sesuai (checkIn atau checkOut)

      if (mounted) {
        widget.fetchUserData(); // Refresh data setelah sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    }
  }

  /// Menentukan posisi terkini dari perangkat.
  /// Meminta izin lokasi jika belum diberikan.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Lokasi tidak aktif, minta pengguna untuk mengaktifkannya.
      return Future.error(
        'Layanan lokasi dinonaktifkan. Mohon aktifkan layanan lokasi Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin ditolak.
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak permanen.
      return Future.error(
        'Izin lokasi ditolak secara permanen. Mohon berikan izin lokasi dari pengaturan aplikasi.',
      );
    }

    // Ketika sampai sini, izin diberikan dan kita bisa mendapatkan posisi.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _showIzinSakitDialog(BuildContext context) {
    final TextEditingController alasanController = TextEditingController();
    String? selectedStatus = 'izin'; // Default selection

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ajukan Izin / Sakit'),
          content: StatefulBuilder(
            // Gunakan StatefulBuilder untuk mengelola state dialog
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'izin', child: Text('Izin')),
                        DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                      ],
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          // setState untuk state dialog
                          selectedStatus = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: alasanController,
                      decoration: const InputDecoration(
                        labelText: 'Alasan',
                        hintText: 'Masukkan alasan izin atau sakit Anda',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () {
                if (alasanController.text.isNotEmpty &&
                    selectedStatus != null) {
                  Navigator.of(dialogContext).pop(); // Tutup dialog
                  _getCurrentLocationAndCheck((position, address) async {
                    await widget.apiService.checkIn(
                      checkInLat: position.latitude,
                      checkInLng: position.longitude,
                      checkInAddress: address,
                      status: selectedStatus!,
                      alasanIzin: alasanController.text,
                    );
                  });
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Status dan Alasan tidak boleh kosong.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final attendance = widget.todayAttendance;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Header Kustom (sesuai desain UI)
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            user?.profilePhotoUrl != null &&
                                    user!.profilePhotoUrl!.isNotEmpty
                                ? NetworkImage(user.profilePhotoUrl!)
                                : null, // Jika URL kosong atau null, gunakan child
                        child:
                            user?.profilePhotoUrl == null ||
                                    user!.profilePhotoUrl!.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Theme.of(context).primaryColor,
                                )
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null
                                  ? _getGreetingMessage(user.jenisKelamin)
                                  : 'Selamat Pagi',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Pengguna',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Informasi tambahan di bawah header jika diperlukan (misal: role, batch)
                  Text(
                    'Email: ${user?.email ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Batch: ${user?.batchId ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Training: ${user?.trainingId ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Spasi antara header dan konten utama
          // Konten Utama - Kartu Presensi Hari Ini
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presensi Hari Ini',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildAttendanceRow(
                      'Check-in:',
                      attendance?.checkInTime ?? 'Belum Check-in',
                      Icons.login,
                    ),
                    _buildAttendanceRow(
                      'Lokasi Check-in:',
                      attendance?.checkInAddress ?? 'N/A',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 10),
                    _buildAttendanceRow(
                      'Check-out:',
                      attendance?.checkOutTime ?? 'Belum Check-out',
                      Icons.logout,
                    ),
                    _buildAttendanceRow(
                      'Lokasi Check-out:',
                      attendance?.checkOutAddress ?? 'N/A',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 10),
                    _buildAttendanceRow(
                      'Status:',
                      attendance?.status ?? 'N/A',
                      Icons.info,
                    ),
                    if (attendance?.alasanIzin != null &&
                        attendance!.alasanIzin!.isNotEmpty)
                      _buildAttendanceRow(
                        'Alasan Izin:',
                        attendance.alasanIzin!,
                        Icons.notes,
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isPerformingAction ||
                                        attendance?.checkInTime != null
                                    ? null
                                    : () => _getCurrentLocationAndCheck((
                                      position,
                                      address,
                                    ) async {
                                      await widget.apiService.checkIn(
                                        checkInLat: position.latitude,
                                        checkInLng: position.longitude,
                                        checkInAddress: address,
                                        status: 'hadir',
                                      );
                                    }),
                            icon:
                                _isPerformingAction &&
                                        (attendance?.checkInTime == null)
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.login),
                            label: Text(
                              attendance?.checkInTime != null
                                  ? 'Sudah Check-in'
                                  : 'Check-in Sekarang',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                _isPerformingAction ||
                                        attendance?.checkOutTime != null ||
                                        attendance?.checkInTime == null
                                    ? null
                                    : () => _getCurrentLocationAndCheck((
                                      position,
                                      address,
                                    ) async {
                                      await widget.apiService.checkOut(
                                        checkOutLat: position.latitude,
                                        checkOutLng: position.longitude,
                                        checkOutAddress: address,
                                      );
                                    }),
                            icon:
                                _isPerformingAction &&
                                        (attendance?.checkInTime != null &&
                                            attendance?.checkOutTime == null)
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.logout),
                            label: Text(
                              attendance?.checkOutTime != null
                                  ? 'Sudah Check-out'
                                  : 'Check-out Sekarang',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Tombol Ajukan Izin/Sakit
                    ElevatedButton(
                      onPressed:
                          _isPerformingAction ||
                                  attendance?.checkInTime !=
                                      null // Disable jika sudah check-in
                              ? null
                              : () {
                                _showIzinSakitDialog(context);
                              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40), // Lebar penuh
                      ),
                      child: const Text('Ajukan Izin / Sakit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Bagian Aktivitas Terbaru (Contoh Placeholder)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Aktivitas Terbaru',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          // Placeholder untuk daftar aktivitas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(16.0),
            height: 120, // Tinggi contoh
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Konten aktivitas atau pengumuman terbaru akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
