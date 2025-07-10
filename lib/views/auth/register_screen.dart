// lib/screens/auth/register_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart'; // Pastikan ini diimpor untuk model Batch dan Training
import 'package:presiva/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.apiService});
  static const String id = '/RegisterScreen';
  final ApiService apiService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  // Add a TextEditingController for the Training field
  final TextEditingController _trainingController = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _busy = false;

  final Batch _fixedBatch2 = Batch(
    id: 1, // <-- MENJADI 1
    batchKe: 'Batch 2',
    startDate: null,
    endDate: null,
  );

  List<Training> _trainings = [];
  Training? _selectedTraining;
  String? _gender;
  File? _photo;

  @override
  void initState() {
    super.initState();
    // Hanya panggil _fetchDropdownData jika masih ada data lain yang perlu diambil (misal: Training)
    // Jika tidak ada lagi, bisa dihapus atau disesuaikan.
    _fetchDropdownData();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    _trainingController.dispose(); // Dispose the new controller
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    setState(() {
      _busy = true;
    });
    try {
      // Hapus baris untuk mengambil batches
      // final fetchedBatches = await widget.apiService.getBatches();

      final fetchedTrainings = await widget.apiService.getTrainings();

      if (mounted) {
        setState(() {
          // Hapus baris terkait _batches dan _selectedBatch
          // _batches = fetchedBatches;
          // if (_batches.isNotEmpty) {
          //   _selectedBatch = _batches.first;
          // }
          _trainings = fetchedTrainings;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) setState(() => _photo = File(picked.path));
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ... (di dalam _RegisterScreenState class)

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // ... (validasi lainnya)

    setState(() => _busy = true);
    try {
      final User? user = await widget.apiService.register(
        name: _name.text,
        email: _email.text,
        password: _pass.text,
        batchId: _fixedBatch2.id,
        jenisKelamin: _gender!,
        trainingId: _selectedTraining!.id,
        // Perbaikan di sini: Tambahkan prefiks Data URI
        profilePhoto:
            _photo != null
                ? 'data:image/png;base64,${base64Encode(await _photo!.readAsBytes())}'
                : null,
      );
      // ...

      if (mounted) {
        setState(() => _busy = false);
        if (user != null) {
          // <--- PENTING: Pengecekan di sini
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Registrasi berhasil!')));
          Navigator.pop(context);
        } else {
          // <--- PENTING: Pesan error jika register mengembalikan null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi gagal. Silakan cek data Anda atau coba lagi nanti.',
              ),
            ),
          );
          // Pastikan Anda juga melihat konsol/log untuk detail error dari ApiService
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        // Ini menangkap error tingkat jaringan atau exception lain
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat registrasi: $e')),
        );
      }
    }
  }

  // ...

  // New function to show training selection bottom sheet
  void _showTrainingSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Start with half screen height
          minChildSize: 0.25,
          maxChildSize: 0.9, // Max height
          expand: false, // Don't expand to full screen by default
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Pilih Jenis Training',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _trainings.length,
                    itemBuilder: (context, index) {
                      final training = _trainings[index];
                      return ListTile(
                        title: Text(training.title),
                        onTap: () {
                          setState(() {
                            _selectedTraining = training;
                            _trainingController.text = training.title;
                          });
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/shaun.jpeg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage('assets/images/shaun.jpeg'),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Buat Akun Anda',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage:
                                  _photo != null ? FileImage(_photo!) : null,
                              child:
                                  _photo == null
                                      ? const Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: Colors.grey,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _name,
                          decoration: _dec('Nama Lengkap', Icons.person),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Nama tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          decoration: _dec('Email', Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(
                              r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,4}$',
                            ).hasMatch(v)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pass,
                          obscureText: _hidePass,
                          decoration: _dec('Password', Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(() => _hidePass = !_hidePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (v.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _hideConfirm,
                          decoration: _dec(
                            'Konfirmasi Password',
                            Icons.lock,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hideConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _hideConfirm = !_hideConfirm,
                                  ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Konfirmasi tidak boleh kosong';
                            }
                            if (v != _pass.text) return 'Password tidak sama';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Dropdown for Jenis Kelamin
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: _dec('Jenis Kelamin', Icons.people),
                          hint: const Text('Pilih Jenis Kelamin'),
                          items: const [
                            DropdownMenuItem(
                              value: 'L',
                              child: Text('Laki-laki'),
                            ),
                            DropdownMenuItem(
                              value: 'P',
                              child: Text('Perempuan'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                          validator:
                              (v) => v == null ? 'Pilih Jenis Kelamin' : null,
                        ),
                        const SizedBox(height: 16),

                        // Batch Pelatihan as a read-only TextFormField (always "Batch 2")
                        TextFormField(
                          decoration: _dec(
                            'Batch Pelatihan',
                            Icons.collections_bookmark,
                          ),
                          readOnly: true,
                          initialValue:
                              _fixedBatch2
                                  .batchKe, // Selalu menampilkan "Batch 2"
                          // Validator dihapus sesuai permintaan
                        ),
                        const SizedBox(height: 16),

                        // Replaced DropdownButtonFormField for Training with TextFormField and custom selection
                        _busy
                            ? const Center(child: CircularProgressIndicator())
                            : TextFormField(
                              controller: _trainingController,
                              readOnly: true, // Make it non-editable
                              onTap:
                                  _trainings.isNotEmpty
                                      ? _showTrainingSelection
                                      : null, // Open bottom sheet on tap
                              decoration: _dec(
                                'Jenis Training',
                                Icons.school,
                              ).copyWith(
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                              validator:
                                  (v) =>
                                      _selectedTraining == null
                                          ? 'Training tidak boleh kosong'
                                          : null,
                            ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: CustomButton(
                            text: 'Register',
                            isLoading: _busy,
                            onPressed: _busy ? null : _submit,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed:
                              _busy ? null : () => Navigator.pop(context),
                          child: Text(
                            'Sudah punya akun? Masuk sekarang',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
