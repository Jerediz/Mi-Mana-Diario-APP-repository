import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dependencies/app_colors_main.dart';
import '../services/bible_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'edit_note_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de tu cuenta'),
        backgroundColor: AppColors.celesteCielo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Correo electrónico'),
              subtitle: Text(userEmail),
            ),

            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Cambiar contraseña'),
              subtitle: const Text('Se enviará un correo de recuperación'),
              onTap: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: userEmail,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📩 Correo de recuperación enviado'),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text(
                      '¿Estás seguro de que quieres cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout ?? false) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Eliminar cuenta',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar cuenta'),
                    content: const Text(
                      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm ?? false) {
                  try {
                    await FirebaseAuth.instance.currentUser?.delete();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Error al eliminar cuenta: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
