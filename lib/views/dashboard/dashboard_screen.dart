import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart'; // Ensure your models are here
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/auth/profile_screen.dart';
import 'package:presiva/views/history/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;

  const DashboardScreen({super.key, required this.apiService});
  static const String id = '/DashboardScreen';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _currentUser;
  Attendance? _todayAttendance;
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _pages = [
      _HomePage(apiService: widget.apiService, fetchUserData: _fetchUserData),
      HistoryScreen(apiService: widget.apiService),
      ProfileScreen(apiService: widget.apiService),
    ];
  }

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
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update _HomePage with current data before building
    if (_selectedIndex == 0) {
      _pages[0] = _HomePage(
        apiService: widget.apiService,
        currentUser: _currentUser,
        todayAttendance: _todayAttendance,
        fetchUserData: _fetchUserData,
      );
    }

    return Scaffold(
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
              : _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // Make the FAB circular
        onPressed: () {
          _onItemTapped(0); // Navigate to Home when FAB is pressed
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8,
        child: const Icon(Icons.home, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () => _onItemTapped(1), // History is at index 1
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ), // <-- DIUBAH DARI 12.0 MENJADI 8.0
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        color:
                            _selectedIndex == 1
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      Text(
                        'History',
                        style: TextStyle(
                          color:
                              _selectedIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox()), // Placeholder for FAB
            Expanded(
              child: InkWell(
                onTap: () => _onItemTapped(2), // Profile is at index 2
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ), // <-- DIUBAH DARI 12.0 MENJADI 8.0
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color:
                            _selectedIndex == 2
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color:
                              _selectedIndex == 2
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  final ApiService apiService;
  final User? currentUser;
  final Attendance? todayAttendance;
  final VoidCallback fetchUserData;

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
  bool _isPerformingAction = false;
  String? _checkInTime;
  String? _checkOutTime;
  String? _checkInLocation;
  String? _checkOutLocation;
  String? _status;
  String? _alasanIzin;

  @override
  void initState() {
    super.initState();
    _updateAttendanceState();
  }

  @override
  void didUpdateWidget(_HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todayAttendance != oldWidget.todayAttendance) {
      _updateAttendanceState();
    }
  }

  void _updateAttendanceState() {
    if (widget.todayAttendance != null) {
      setState(() {
        _checkInTime = widget.todayAttendance!.checkIn;
        _checkOutTime = widget.todayAttendance!.checkOut;
        _checkInLocation = widget.todayAttendance!.checkInAddress;
        _checkOutLocation = widget.todayAttendance!.checkOutAddress;
        _status = widget.todayAttendance!.status;
        _alasanIzin = widget.todayAttendance!.alasanIzin;
      });
    } else {
      setState(() {
        _checkInTime = null;
        _checkOutTime = null;
        _checkInLocation = null;
        _checkOutLocation = null;
        _status = null;
        _alasanIzin = null;
      });
    }
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

    // Using 'L' for Laki-laki and 'P' for Perempuan based on Postman API
    if (jenisKelamin == 'L') {
      return '$greeting Gantengku';
    } else if (jenisKelamin == 'P') {
      return '$greeting Cantikku';
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

      await apiCall(position, address);

      if (mounted) {
        widget.fetchUserData(); // Refresh data after action
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Layanan lokasi dinonaktifkan. Mohon aktifkan layanan lokasi Anda.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Izin lokasi ditolak secara permanen. Mohon berikan izin lokasi dari pengaturan aplikasi.',
      );
    }

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
                  Navigator.of(dialogContext).pop();
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

  Widget _buildUserInfoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90, // Adjust width as needed to align values
            child: Text(
              '$title:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
    final user = widget.currentUser;
    // Removed DateFormat for date and time. Using basic toString()
    final String formattedDate =
        DateTime.now().toLocal().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final String formattedTime = DateTime.now()
        .toLocal()
        .toString()
        .split(' ')[1]
        .substring(0, 5); // HH:MM

    return Scaffold(
      backgroundColor:
          Colors.grey[100], // Light grey background for the whole page
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - Gradient Background and User Info
            Stack(
              children: [
                Container(
                  height: 280, // Increased height to match image better
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        const Color(0xFF6A1B9A), // A deeper purple
                        Colors.deepPurpleAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40), // More rounded
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/shaun.jpeg', // Ensure this image is in your assets
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(
                      0.1,
                    ), // Subtle opacity
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                Positioned(
                  top: 60, // Adjusted for status bar and spacing
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  3,
                                ), // White border
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 35, // Larger avatar
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      user?.profilePhotoUrl != null &&
                                              user!.profilePhotoUrl!.isNotEmpty
                                          ? NetworkImage(user.profilePhotoUrl!)
                                          : null,
                                  child:
                                      user?.profilePhotoUrl == null ||
                                              user!.profilePhotoUrl!.isEmpty
                                          ? Icon(
                                            Icons.person,
                                            size: 45, // Larger icon
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user != null
                                          ? _getGreetingMessage(
                                            user.jenisKelamin,
                                          )
                                          : 'Selamat Pagi',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.name ?? 'Pengguna',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26, // Larger name font
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          // User Details
                          _buildUserInfoText('Email', user?.email ?? 'N/A'),
                          _buildUserInfoText(
                            'Batch',
                            user?.batch?.batchKe ?? 'N/A',
                          ),
                          _buildUserInfoText(
                            'Training',
                            user?.training?.title ?? 'N/A',
                          ),
                          _buildUserInfoText(
                            'Jenis Kelamin',
                            user?.jenisKelamin == 'L'
                                ? 'Laki-laki'
                                : user?.jenisKelamin == 'P'
                                ? 'Perempuan'
                                : 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Current Date and Time Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 42, // Larger time font
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Attendance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 10, // More prominent shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // More rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Presensi Hari Ini',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 22,
                        ),
                      ),
                      const Divider(
                        height: 30,
                        thickness: 1.8,
                        color: Colors.grey,
                      ),
                      _buildAttendanceRow(
                        'Check-in',
                        _checkInTime ?? 'Belum Check-in',
                        Icons.login,
                        _checkInTime != null ? Colors.green : Colors.orange,
                      ),
                      _buildAttendanceRow(
                        'Lokasi Check-in',
                        _checkInLocation ?? 'N/A',
                        Icons.location_on,
                        _checkInLocation != null ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      _buildAttendanceRow(
                        'Check-out',
                        _checkOutTime ?? 'Belum Check-out',
                        Icons.logout,
                        _checkOutTime != null ? Colors.red : Colors.orange,
                      ),
                      _buildAttendanceRow(
                        'Lokasi Check-out',
                        _checkOutLocation ?? 'N/A',
                        Icons.location_on,
                        _checkOutLocation != null ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      _buildAttendanceRow(
                        'Status',
                        _status ?? 'N/A',
                        Icons.info,
                        _status == 'masuk'
                            ? Colors.green
                            : (_status == 'izin' || _status == 'sakit'
                                ? Colors.orange
                                : Colors.grey),
                      ),
                      if (_alasanIzin != null && _alasanIzin!.isNotEmpty)
                        _buildAttendanceRow(
                          'Alasan Izin',
                          _alasanIzin!,
                          Icons.notes,
                          Colors.purple,
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isPerformingAction || _checkInTime != null
                                      ? null
                                      : () => _getCurrentLocationAndCheck((
                                        position,
                                        address,
                                      ) async {
                                        await widget.apiService.checkIn(
                                          checkInLat: position.latitude,
                                          checkInLng: position.longitude,
                                          checkInAddress: address,
                                          status: 'masuk',
                                        );
                                      }),
                              icon:
                                  _isPerformingAction && (_checkInTime == null)
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.login_rounded,
                                        size: 28,
                                      ),
                              label: Text(
                                _checkInTime != null
                                    ? 'Sudah Check-in'
                                    : 'Check-in Sekarang',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Green for check-in
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Slightly more rounded
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isPerformingAction ||
                                          _checkOutTime != null ||
                                          _checkInTime == null
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
                                          (_checkInTime != null &&
                                              _checkOutTime == null)
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.logout_rounded,
                                        size: 28,
                                      ),
                              label: Text(
                                _checkOutTime != null
                                    ? 'Sudah Check-out'
                                    : 'Check-out Sekarang',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 17),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red, // Red for check-out
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Izin / Sakit button
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed:
                              _isPerformingAction ||
                                      _checkInTime != null ||
                                      _status == 'izin' ||
                                      _status == 'sakit'
                                  ? null
                                  : () => _showIzinSakitDialog(context),
                          icon: const Icon(Icons.sick, color: Colors.orange),
                          label: Text(
                            _status == 'izin'
                                ? 'Status: Izin'
                                : _status == 'sakit'
                                ? 'Status: Sakit'
                                : 'Ajukan Izin / Sakit',
                            style: TextStyle(
                              color:
                                  _status == 'izin' || _status == 'sakit'
                                      ? Colors.orange
                                      : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom navigation bar
          ],
        ),
      ),
    );
  }
}
