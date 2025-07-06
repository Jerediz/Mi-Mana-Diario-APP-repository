import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mi_mana_diario/dependencies/app_colors_main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _noteController.text.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('notes').add({
        'title': _titleController.text.trim(),
        'note': _noteController.text.trim(),
        'created_at': Timestamp.now(),
        'userId': user?.uid,
      });

      // Detectar si hay conexión a internet
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity == ConnectivityResult.none;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOffline
                ? '📴 Nota guardada localmente. Se subirá al reconectar.'
                : '✅ Nota guardada exitosamente en la nube',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al guardar: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Nota'),
        backgroundColor: AppColors.celesteCielo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top, // <- ESTO ES LA CLAVE
                autocorrect: true,
                decoration: const InputDecoration(
                  labelText: 'Escribe tu nota...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _isSaving ? null : _saveNote,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.floppy_disk, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isSaving ? 'Guardando...' : 'Guardar Nota',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
