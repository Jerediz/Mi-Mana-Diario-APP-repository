import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mi_mana_diario/screens/login_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  
  Widget build(BuildContext context) {
  double opacityLevel = 1.0;
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            AnimatedOpacity(
          opacity: opacityLevel,
          duration: const Duration(seconds: 5),
          child: const FlutterLogo(),),
            SizedBox(
              height: 450.0,
              width: 450.0,
              child: Image.asset('assets/home.png'),
            ),
            Text(
            'Bienvenido a:',
            style: TextStyle(fontSize: 20,)
            ),
            Text(
            'Mi Maná Diario',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,)
            ),
            SizedBox(height: 5,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 21.0),
              child:Text(
              'Una app para conectar con la Palabra de Dios cada día. Lee un capítulo, medita, y escribe lo que el Espíritu te revela. Hoy, Dios quiere hablarte.',
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 25,),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CupertinoButton.filled(
              child: const Text('Iniciar Sesión'),
              onPressed: () {
              Navigator.of(context).push(_createRoute());
              },
            )
            )
          ],
        ),
      ),
    );
  }

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
}