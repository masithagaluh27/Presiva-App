// // lib/screens/profile/profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:presiva/api/api_service.dart';
// import 'package:presiva/models/app_models.dart';
// import 'package:presiva/widgets/custom_button.dart';
// import 'package:presiva/widgets/loading_indicator.dart';

// class ProfileScreen extends StatefulWidget {
//   final ApiService apiService;

//   const ProfileScreen({super.key, required this.apiService});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();

//   User? _currentUser;
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }

//   Future<void> _fetchUserProfile() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final user = await widget.apiService.getProfile();
//       setState(() {
//         _currentUser = user;
//         if (user != null) {
//           _nameController.text = user.name;
//           _emailController.text = user.email;
//         }
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load profile: $e';
//         _isLoading = false;
//       });
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       final updatedUser = await widget.apiService.updateProfile(
//         name: _nameController.text,
//         email: _emailController.text,
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (!mounted) return;

//       if (updatedUser != null) {
//         setState(() {
//           _currentUser = updatedUser;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profil berhasil diperbarui!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Gagal memperbarui profil. Mohon coba lagi.'),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profil Pengguna'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : _errorMessage != null
//               ? Center(
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               )
//               : _currentUser == null
//               ? const Center(child: Text('Tidak dapat memuat data profil.'))
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       const CircleAvatar(
//                         radius: 60,
//                         child: Icon(Icons.person, size: 60),
//                       ),
//                       const SizedBox(height: 24),
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Nama Lengkap',
//                           prefixIcon: Icon(Icons.person),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Nama tidak boleh kosong';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           prefixIcon: Icon(Icons.email),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Email tidak boleh kosong';
//                           }
//                           if (!value.contains('@')) {
//                             return 'Format email tidak valid';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Batch ID: ${_currentUser!.batchId ?? "N/A"}',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Training ID: ${_currentUser!.trainingId ?? "N/A"}',
//                         style: Theme.of(context).textTheme.bodyLarge,
//                       ),
//                       const SizedBox(height: 32),
//                       CustomButton(
//                         text: 'Simpan Perubahan',
//                         onPressed: _isLoading ? null : _updateProfile,
//                         isLoading: _isLoading,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
// }
