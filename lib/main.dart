import 'package:flutter/material.dart';
import 'package:presiva/splash_screen.dart';
import 'package:presiva/utils/app_color.dart';
import 'package:presiva/views/auth/login_screen.dart';
import 'package:presiva/views/auth/register_screen.dart';
import 'package:presiva/views/dashboard/dashboard_screen.dart';
import 'package:presiva/views/profile/profile_screen.dart';

import 'api/api_provider.dart';
import 'helper/preference_handler.dart'; // Pastikan ini di-import
import 'utils/app_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();

  final apiService = ApiService(baseUrl: AppConstants.baseUrl);

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme, // Tema yang digunakan
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(apiService: apiService),
        LoginScreen.id: (context) => LoginScreen(apiService: apiService),
        RegisterScreen.id: (context) => RegisterScreen(apiService: apiService),
        DashboardScreen.id:
            (context) => DashboardScreen(apiService: apiService),

        ProfileScreen.id: (context) => ProfileScreen(apiService: apiService),
      },
    );
  }
}
