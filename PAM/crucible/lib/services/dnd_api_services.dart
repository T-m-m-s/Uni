import 'dart:convert';
import 'package:http/http.dart' as http;

class DndApiService {
  static const String _baseUrl = 'https://api.open5e.com';

  // Cerca incantesimi tramite testo parziale
  Future<List<dynamic>> searchSpells(String query) async {
    if (query.length < 3) return []; // Non cercare se < 3 lettere

    final url = Uri.parse('$_baseUrl/spells/?search=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results']; // Ritorna la lista grezza
      } else {
        throw Exception('Errore API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore di connessione: $e');
      return [];
    }
  }
}