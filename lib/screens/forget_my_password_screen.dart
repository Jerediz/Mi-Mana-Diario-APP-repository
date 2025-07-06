import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ForgetMyPasswordScreen extends StatefulWidget {
  const ForgetMyPasswordScreen({super.key});

  @override
  State<ForgetMyPasswordScreen> createState() => _ForgetMyPasswordScreenState();
}

class _ForgetMyPasswordScreenState extends State<ForgetMyPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, ingresa tu correo.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        successMessage =
            '📩 Te enviamos un correo para restablecer tu contraseña.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'El correo ingresado no es válido.';
            break;
          case 'user-not-found':
            errorMessage = 'No encontramos una cuenta con ese correo.';
            break;
          default:
            errorMessage = e.message ?? 'Algo salió mal. Intenta de nuevo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recupera tu cuenta'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
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
                  height: 250.0,
                  width: 250.0,
                  child: Image.asset('assets/forgetimg.png'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 310,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo electrónico',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 14),
                CupertinoButton.filled(
                  onPressed: resetPassword,
                  child: const Text('Enviar enlace de recuperación'),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                  child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
                ),
                const SizedBox(height: 12),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                if (successMessage.isNotEmpty)
                  Text(
                    successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
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
          const LoginScreen(),
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
}
