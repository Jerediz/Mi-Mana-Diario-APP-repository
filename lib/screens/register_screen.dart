import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

Future<void> register() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    setState(() {
      errorMessage = 'Por favor, completa todos los campos.';
    });
    return;
  }

  if (!email.contains('@') || !email.contains('.')) {
    setState(() {
      errorMessage = 'El correo electrónico no es válido.';
    });
    return;
  }

  if (password.length < 6) {
    setState(() {
      errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
    });
    return;
  }

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    Navigator.pushReplacementNamed(context, '/mainhome');
  } on FirebaseAuthException catch (e) {
    setState(() {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está registrado.';
          break;
        case 'invalid-email':
          errorMessage = 'Correo inválido.';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil.';
          break;
        default:
          errorMessage = e.message ?? 'Error desconocido al registrar.';
      }
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: Text('Registrarse'),
        centerTitle: true,
        shadowColor: Colors.black,
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
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
                autofillHints: [AutofillHints.email],
                controller: emailController,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Correo electrónico'))),
            SizedBox(height: 12),
            SizedBox(
                width: 310,
                child: TextField(
                obscureText: true,
                controller: passwordController,
                autofillHints: [AutofillHints.password],
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Contraseña'))),
            SizedBox(height: 24),
            CupertinoButton.filled(
              onPressed: register,
              child: Text('Registrate'),
            ),
            CupertinoButton(
              onPressed: () {
              Navigator.of(context).push(_createRoute());
              },
              child: Text('¿Ya tienes una cuenta? Inicia Sesión'),
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
    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
}
