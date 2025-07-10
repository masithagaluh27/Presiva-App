// lib/screens/profile/edit_profile_screen.dart
import 'dart:io'; // Digunakan untuk objek File
import 'dart:convert'; // Digunakan untuk konversi Base64

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan Anda menambahkan ini ke pubspec.yaml
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/models/app_models.dart';

class EditProfileScreen extends StatefulWidget {
  final ApiService apiService;
  final User currentUser;
  final VoidCallback
  onProfileUpdated; // Callback untuk memicu refresh di ProfileScreen

  const EditProfileScreen({
    super.key,
    required this.apiService,
    required this.currentUser,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _imageFile; // Menyimpan gambar yang dipilih dari galeri
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality:
          80, // Mengurangi kualitas untuk ukuran file yang lebih kecil
      maxWidth: 800, // Mengatur lebar maksimum
      maxHeight: 800, // Mengatur tinggi maksimum
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk memperbarui profil (termasuk foto)
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? base64Image;
      if (_imageFile != null) {
        // Konversi File gambar ke Base64 String
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      try {
        final updatedUser = await widget.apiService.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          profilePhoto:
              base64Image, // Meneruskan Base64 String gambar yang dipilih
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        if (updatedUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
          widget
              .onProfileUpdated(); // Panggil callback untuk me-refresh ProfileScreen
          Navigator.of(context).pop(); // Kembali ke ProfileScreen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui profil. Mohon coba lagi.'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memperbarui profil: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // Hapus bayangan appBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bagian Foto Profil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70, // Ukuran avatar lebih besar
                      backgroundColor: Colors.grey[200],
                      // Tampilkan gambar yang dipilih, jika tidak ada, tampilkan dari URL API, jika tidak ada juga tampilkan ikon
                      backgroundImage:
                          _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider<Object>?
                              : (widget.currentUser.profilePhotoUrl != null &&
                                      widget
                                          .currentUser
                                          .profilePhotoUrl!
                                          .isNotEmpty
                                  ? NetworkImage(
                                    widget.currentUser.profilePhotoUrl!,
                                  )
                                  : null),
                      child:
                          _imageFile == null &&
                                  (widget.currentUser.profilePhotoUrl == null ||
                                      widget
                                          .currentUser
                                          .profilePhotoUrl!
                                          .isEmpty)
                              ? Icon(
                                Icons.person,
                                size: 70, // Ukuran ikon lebih besar
                                color: Theme.of(context).primaryColor,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap:
                            _pickImage, // Panggil fungsi memilih gambar saat diklik
                        child: Container(
                          padding: const EdgeInsets.all(
                            8,
                          ), // Padding di sekitar ikon kamera
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ), // Border putih
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 32,
              ), // Jarak lebih besar setelah foto profil
              // Input Nama Lengkap
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut membulat
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut membulat
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    // Validasi email yang lebih baik
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan Perubahan
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut membulat
                  ),
                  elevation: 5, // Sedikit bayangan
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
