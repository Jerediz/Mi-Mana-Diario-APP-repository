import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../services/bible_api.dart';
import 'package:google_fonts/google_fonts.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  final BibleApiService _service = BibleApiService();
  String title = 'Cargando capítulo...';
  String content = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapterWithCache();
  }

  // Carga con caché + refresco en segundo plano
  Future<void> _loadChapterWithCache({bool force = false}) async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();

    if (!force) {
      final cachedTitle = prefs.getString('chapter_title_$todayKey');
      final cachedContent = prefs.getString('chapter_content_$todayKey');

      if (cachedTitle != null && cachedContent != null) {
        setState(() {
          title = cachedTitle;
          content = cachedContent;
          loading = false;
        });

        // refresco en segundo plano
        _loadChapterWithCache(force: true);
        return;
      }
    }

    try {
      final data = await _service.fetchRandomChapterOfTheDay();
      final chapterTitle = data['title'] ?? 'Capítulo';
      final chapterContent = data['content'] ?? '';

      await prefs.setString('chapter_title_$todayKey', chapterTitle);
      await prefs.setString('chapter_content_$todayKey', chapterContent);

      setState(() {
        title = chapterTitle;
        content = chapterContent;
        loading = false;
      });
    } catch (e) {
      setState(() {
        title = 'Error';
        content = 'No se pudo cargar el capítulo.\n\n$e';
        loading = false;
      });
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: '$title\n\n$content'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 Texto copiado al portapapeles')),
    );
  }

  void _shareChapter() {
    Share.share('$title\n\n$content');
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⭐️ Capítulo añadido a favoritos')),
    );
    // Aquí puedes guardar en Firestore o local si quieres
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'Merriweather')),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadChapterWithCache(force: true),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        fontFamily: 'Merriweather',
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.white,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.edit_outlined,
                        color: Colors.grey,
                      ),
                      title: const Text('Agrega tu reflexión personal'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/notescreen');
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                      ),
                      title: const Text('Agregar a Favoritos'),
                      onTap: () {
                        Navigator.pop(context);
                        _addToFavorites();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.blue),
                      title: const Text('Compartir capítulo'),
                      onTap: () {
                        Navigator.pop(context);
                        _shareChapter();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.copy, color: Colors.grey),
                      title: const Text('Copiar texto'),
                      onTap: () {
                        Navigator.pop(context);
                        _copyToClipboard();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shuffle, color: Colors.purple),
                      title: const Text('Cambiar capítulo'),
                      onTap: () async {
                        Navigator.pop(context); // Cierra el modal

                        setState(() {
                          loading = true;
                          title = 'Cambiando capítulo...';
                          content = '';
                        });

                        try {
                          final data = await _service
                              .fetchRandomChapterOfTheDay(forceRefresh: true);
                          setState(() {
                            title = data['title'] ?? 'Capítulo';
                            content = data['content'] ?? '';
                            loading = false;
                          });

                          // Regresa true al salir de la pantalla si se cambió el capítulo
                          Navigator.pop(context, true);
                        } catch (e) {
                          setState(() {
                            title = 'Error';
                            content = 'No se pudo cargar el capítulo.\n$e';
                            loading = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.comment),
      ),
    );
  }
}
