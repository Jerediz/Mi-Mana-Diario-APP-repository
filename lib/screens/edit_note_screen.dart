import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  final String initialTitle;
  final String initialContent;

  const EditNoteScreen({
    Key? key,
    required this.noteId,
    required this.initialTitle,
    required this.initialContent,
  }) : super(key: key);

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _noteController = TextEditingController(text: widget.initialContent);
  }

  void _saveNote() async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).update({
        'title': _titleController.text.trim(),
        'note': _noteController.text.trim(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final content = _noteController.text.trim();
    Share.share('$title\n\n$content');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNote,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Nota'),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
