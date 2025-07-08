import 'package:flutter/material.dart';
import 'package:presiva/api/api_provider.dart';
import 'package:presiva/views/auth/register_screen.dart';
import 'package:presiva/views/dashboard/dashboard_screen.dart';

/// ---------------------------------------------------------------------------
///  LoginScreen – clean & responsive
/// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.apiService});
  static const String id = '/loginScreen';
  final ApiService apiService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _busy = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final token = await widget.apiService.login(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(apiService: widget.apiService),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal! Cek email & password.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gambar background penuh
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset('assets/images/shaun.jpeg', fit: BoxFit.cover),
          ),

          // Overlay gelap agar teks lebih terbaca
          Container(color: Colors.black.withOpacity(0.3)),

          // Konten
          Column(
            children: [
              const Spacer(),

              // ---------- white sheet ----------
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundImage: AssetImage('assets/images/shaun.jpeg'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Login in to Presiva',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Securely access your email, calendar, and files — all in one place.',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 32),

                      // email
                      _buildField(
                        controller: _email,
                        hint: 'Email Address',
                        keyboard: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Email tidak boleh kosong';
                          if (!v.contains('@'))
                            return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // password
                      _buildField(
                        controller: _password,
                        hint: 'Password',
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password tidak boleh kosong';
                          if (v.length < 6)
                            return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // forgot pwd
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed:
                              _busy
                                  ? null
                                  : () => ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Fitur lupa password belum diimplementasi.',
                                      ),
                                    ),
                                  ),
                          child: const Text('Forgot your Password?'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // login btn
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _busy ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child:
                              _busy
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Log In',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // sign up
                      TextButton(
                        onPressed:
                            _busy
                                ? null
                                : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => RegisterScreen(
                                          apiService: widget.apiService,
                                        ),
                                  ),
                                ),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black),
                            children: const [
                              TextSpan(
                                text: 'Create an account',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
