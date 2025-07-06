import 'package:flutter/material.dart';
import 'package:mi_mana_diario/screens/about_app_screen.dart';
import 'package:mi_mana_diario/screens/account_settings_screen.dart';
import 'package:mi_mana_diario/screens/forget_my_password_screen.dart';
import 'package:mi_mana_diario/screens/note_screen.dart';
import 'dependencies/app_colors_main.dart';
import 'screens/home_screen.dart';
import 'screens/main_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/chapter_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await initializeDateFormatting('es', null);
  runApp(const MiManaDiario());
}

class MiManaDiario extends StatelessWidget {
  const MiManaDiario({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Maná Diario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.celesteCielo),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const MainHomeScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/mainhome': (context) => const MainHomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/chapter': (context) => const ChapterScreen(),
        '/notescreen': (context) => const NoteScreen(),
        '/forgetpassword': (context) => const ForgetMyPasswordScreen(),
        '/accountsettings': (context) => const AccountSettingsScreen(),
        '/about': (context) => const AboutAppScreen(),
      },
    );
  }
}
