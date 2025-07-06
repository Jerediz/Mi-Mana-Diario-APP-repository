import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mi_mana_diario/screens/forget_my_password_screen.dart';
import 'package:mi_mana_diario/screens/register_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, completa todos los campos.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print("🔴Login exitoso");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = "El correo no es válido.";
            break;
          case 'user-not-found':
            errorMessage = "Este usuario no está registrado.";
            break;
          case 'wrong-password':
            errorMessage = "La contraseña es incorrecta.";
            break;
          case 'user-disabled':
            errorMessage = "Esta cuenta ha sido deshabilitada.";
            break;
          default:
            errorMessage = e.message ?? "Error desconocido al iniciar sesión.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Esto sí vuelve atrás
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300.0,
                  width: 400.0,
                  child: Image.asset('assets/home.png'),
                ),
                SizedBox(
                  width: 310,
                  child: TextField(
                    controller: emailController,
                    autofillHints: [AutofillHints.email],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo electrónico',
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: 310,
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    autofillHints: [AutofillHints.password],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Contraseña',
                    ),
                  ),
                ),
                SizedBox(height: 24),
                CupertinoButton.filled(
                  onPressed: login,
                  child: Text('Iniciar Sesión'),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  child: Text('¿No tienes una cuenta? Registrate'),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute2());
                  },
                  child: Text('Olvidé mi contraseña'),
                ),
                SizedBox(height: 12),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const RegisterScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Route _createRoute2() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ForgetMyPasswordScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
