// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:presiva/api/api_service.dart';
import 'package:presiva/models/app_models.dart'; // Untuk Batch dan Training
import 'package:presiva/widgets/custom_button.dart';
import 'package:presiva/widgets/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  final ApiService apiService;

  const RegisterScreen({super.key, required this.apiService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool _confirmObscureText = true;
  bool _isLoading = false;

  List<Batch> _batches = [];
  Batch? _selectedBatch;
  int? _selectedTrainingId; // Asumsi trainingId akan dipilih setelah batch

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    // Di sini kita tidak menggunakan Provider, jadi panggil langsung apiService
    final batches = await widget.apiService.listAllBatches();
    if (batches != null) {
      setState(() {
        _batches = batches;
        // Optionally pre-select the first batch if available
        // _selectedBatch = batches.isNotEmpty ? batches.first : null;
      });
    } else {
      // Handle error fetching batches
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load batches.')));
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _confirmObscureText = !_confirmObscureText;
    });
  }

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatch == null || _selectedTrainingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih Batch dan Training terlebih dahulu.'),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newUser = await widget.apiService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        batchId: _selectedBatch!.id,
        trainingId: _selectedTrainingId!,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (newUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.of(context).pop(); // Kembali ke halaman login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal. Mohon coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Buat Akun Anda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _confirmObscureText,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmObscureText
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: _toggleConfirmPasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown untuk memilih Batch
                DropdownButtonFormField<Batch>(
                  value: _selectedBatch,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Batch',
                    prefixIcon: Icon(Icons.groups),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Pilih Batch'),
                  items:
                      _batches.map((batch) {
                        return DropdownMenuItem<Batch>(
                          value: batch,
                          child: Text(batch.name),
                        );
                      }).toList(),
                  onChanged: (Batch? newValue) {
                    setState(() {
                      _selectedBatch = newValue;
                      // Ketika batch berubah, Anda mungkin perlu memuat training yang relevan.
                      // Untuk contoh ini, kita hardcode atau asumsikan ID training.
                      // Dalam aplikasi nyata, Anda mungkin memiliki endpoint API untuk mendapatkan training berdasarkan batch.
                      _selectedTrainingId = 1; // Contoh: hardcode training ID 1
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Harap pilih Batch';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Field untuk Training ID (bisa juga Dropdown jika ada list training)
                // Untuk contoh ini, kita asumsikan setelah memilih batch, training ID sudah ditentukan
                // Atau Anda bisa menggunakan Dropdown lain untuk memilih Training
                TextFormField(
                  readOnly:
                      true, // Karena ini akan diisi otomatis atau dipilih dari Dropdown lain
                  decoration: InputDecoration(
                    labelText: 'ID Training',
                    prefixIcon: const Icon(Icons.school),
                    hintText:
                        _selectedTrainingId?.toString() ?? 'Pilih Batch dulu',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedTrainingId == null) {
                      return 'ID Training tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Daftar',
                  onPressed: _isLoading ? null : _submitRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            Navigator.of(
                              context,
                            ).pop(); // Kembali ke halaman login
                          },
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
