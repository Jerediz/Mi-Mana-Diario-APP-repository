import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleApiService {
  final String _baseUrl = 'https://api.scripture.api.bible/v1';
  final String _apiKey = '17192b01c4bac29eedacb709af80615c';
  final String _bibleId = '592420522e16049f-01';

  Future<Map<String, String>> fetchRandomChapterOfTheDay({
    bool forceRefresh = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey =
        'chapter_${DateTime.now().toIso8601String().substring(0, 10)}';

    if (!forceRefresh && prefs.containsKey(todayKey)) {
      final cached = json.decode(prefs.getString(todayKey)!);
      return {'title': cached['title'], 'content': cached['content']};
    }

    final rng = Random(DateTime.now().millisecondsSinceEpoch);

    // Obtener todos los libros
    final booksUri = Uri.parse('$_baseUrl/bibles/$_bibleId/books');
    final booksRes = await http.get(booksUri, headers: {'api-key': _apiKey});
    if (booksRes.statusCode != 200) throw Exception('Error al obtener libros');

    final booksData = json.decode(booksRes.body)['data'];
    final randomBook = booksData[rng.nextInt(booksData.length)];
    final bookId = randomBook['id'];
    final bookName = randomBook['name'];

    // Obtener capítulos del libro seleccionado
    final chaptersUri = Uri.parse(
      '$_baseUrl/bibles/$_bibleId/books/$bookId/chapters',
    );
    final chaptersRes = await http.get(
      chaptersUri,
      headers: {'api-key': _apiKey},
    );
    if (chaptersRes.statusCode != 200)
      throw Exception('Error al obtener capítulos');

    final chaptersData = json.decode(chaptersRes.body)['data'];
    final randomChapter = chaptersData[rng.nextInt(chaptersData.length)];
    final chapterId = randomChapter['id'];
    final chapterNumber = randomChapter['number'];
    final title = '$bookName $chapterNumber';

    // Obtener contenido del capítulo
    final chapterUri = Uri.parse(
      '$_baseUrl/bibles/$_bibleId/chapters/$chapterId',
    );
    final chapterRes = await http.get(
      chapterUri,
      headers: {'api-key': _apiKey},
    );
    if (chapterRes.statusCode != 200)
      throw Exception('Error al obtener capítulo');

    final chapterData = json.decode(chapterRes.body)['data'];

    // Limpiar el texto
    final rawHtml = chapterData['content'] ?? '';
    final cleanText = _formatVerses(rawHtml);

    prefs.setString(
      todayKey,
      json.encode({'title': title, 'content': cleanText}),
    );

    return {'title': title, 'content': cleanText};
  }

  String _formatVerses(String rawHtml) {
    final withoutHtml = rawHtml.replaceAll(RegExp(r'<[^>]+>'), '');

    // Formato para poner cada versículo separado, bien bonito
    final formatted = withoutHtml.replaceAllMapped(
      RegExp(r'(\d+)(?=[A-ZÑ])'), // Números pegados al texto (ej. "17Y...")
      (match) => '\n\n${match.group(1)}. ',
    );

    return formatted.trim();
  }
}
