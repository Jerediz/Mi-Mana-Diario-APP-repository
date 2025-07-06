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

import 'package:flutter/services.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationExample();
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  String citationText = 'Cargando cita...';
  late Future<List<QueryDocumentSnapshot>> _notesFuture;

  final BibleApiService _chapterService = BibleApiService();

  @override
  void initState() {
    super.initState();
    _loadCitation();
    _notesFuture = _loadNotes();
  }

  Future<List<QueryDocumentSnapshot>> _loadNotes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notes')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs;
  }

  void _loadCitation() async {
    try {
      Map<String, String> chapter = await _chapterService
          .fetchRandomChapterOfTheDay();
      String title = chapter['title'] ?? 'Capítulo del día';

      setState(() {
        citationText = title;
      });
    } catch (e) {
      setState(() {
        citationText = "Error al cargar";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final now = DateTime.now();
    final String dateText =
        'Hoy es ${DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'es_ES').format(now)}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Maná Diario'),
        backgroundColor: AppColors.celesteCielo,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: AppColors.celesteCielo,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list_sharp),
            icon: Icon(Icons.list),
            label: 'Capítulos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings_sharp),
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
      body: <Widget>[
        // INICIO
        Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/main_home.jpg', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.6)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dateText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu capítulo para hoy es:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoButton.filled(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/chapter',
                        );

                        if (result == true) {
                          // Si se cambió el capítulo en ChapterScreen, recarga el botón
                          _loadCitation();
                        }
                      },
                      child: Text(citationText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // CAPÍTULOS (Notas)
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where(
                'userId',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid,
              )
              .orderBy('created_at', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay notas aún.'));
            }

            final notes = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final data = note.data() as Map<String, dynamic>;

                final title = data['title'] ?? '';
                final content = data['note'] ?? '';
                final isFavorite = data['favorite'] ?? false;
                final chapterRef = data['chapterReference'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('notes')
                            .doc(note.id)
                            .update({'favorite': !isFavorite});
                      },
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (chapterRef.isNotEmpty)
                          Text(
                            '📖 Capítulo: $chapterRef',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteScreen(
                                noteId: note.id,
                                initialTitle: title,
                                initialContent: content,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          FirebaseFirestore.instance
                              .collection('notes')
                              .doc(note.id)
                              .delete();
                        } else if (value == 'share') {
                          Share.share('$title\n\n$content');
                        } else if (value == 'copy') {
                          Clipboard.setData(
                            ClipboardData(text: '$title\n\n$content'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Texto copiado')),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                        PopupMenuItem(value: 'share', child: Text('Compartir')),
                        PopupMenuItem(value: 'copy', child: Text('Copiar')),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),

        // CONFIGURACIÓN
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Opción para ir a Ajustes de Cuenta
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Ajustes de cuenta'),
                subtitle: const Text(
                  'Ver tu correo, cambiar contraseña, cerrrar sesión o eliminar cuenta',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/accountsettings');
                },
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de la app'),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
