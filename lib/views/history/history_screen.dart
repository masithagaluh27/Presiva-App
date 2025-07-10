// lib/screens/history/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart';

class HistoryScreen extends StatefulWidget {
  final ApiService apiService;

  const HistoryScreen({super.key, required this.apiService});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Attendance>? _attendanceHistory;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final history = await widget.apiService.getAttendanceHistory();
      setState(() {
        _attendanceHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load attendance history: $e';
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absen'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchAttendanceHistory,
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
              : _attendanceHistory == null || _attendanceHistory!.isEmpty
              ? const Center(child: Text('Belum ada riwayat absen.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _attendanceHistory!.length,
                itemBuilder: (context, index) {
                  final attendance = _attendanceHistory![index];
                  // Parse checkIn string to DateTime
                  final checkInDateTime = DateTime.tryParse(attendance.checkIn);
                  // Format the date if parsing is successful
                  final formattedDate =
                      checkInDateTime != null
                          ? DateFormat('dd MMMM yyyy').format(checkInDateTime)
                          : 'N/A'; // Or handle error appropriately

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal: $formattedDate', // Use the formatted date
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Check-in: ${attendance.checkIn}'),
                          Text('Status: ${attendance.status}'),
                          if (attendance.checkOut != null)
                            Text('Check-out: ${attendance.checkOut}'),
                          if (attendance.alasanIzin != null &&
                              attendance.alasanIzin!.isNotEmpty)
                            Text('Alasan: ${attendance.alasanIzin}'),
                          // Anda bisa menambahkan detail lain seperti lokasi
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
