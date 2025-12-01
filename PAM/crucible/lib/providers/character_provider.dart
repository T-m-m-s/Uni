import 'dart:convert'; // Importante per JSON
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante
import '../models/character.dart';
import '../services/pdf_service.dart';

class CharacterProvider with ChangeNotifier {
  List<Character> _characters = [];
  final PdfService _pdfService = PdfService();

  List<Character> get characters => _characters;

  // COSTRUTTORE: Carica i dati appena l'app parte
  CharacterProvider() {
    loadData();
  }

  // --- LOGICA DI SALVATAGGIO/CARICAMENTO ---

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Cerchiamo se c'è una lista salvata con la chiave 'saved_characters'
    final String? dataString = prefs.getString('saved_characters');

    if (dataString != null) {
      // Decodifichiamo: Stringa -> Lista di JSON -> Lista di Character
      final List<dynamic> jsonList = json.decode(dataString);
      _characters = jsonList.map((jsonItem) => Character.fromJson(jsonItem)).toList();
      notifyListeners(); // Avvisa la UI che i dati sono arrivati
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Codifichiamo: Lista di Character -> Lista di JSON -> Stringa
    final String dataString = json.encode(_characters.map((e) => e.toJson()).toList());
    await prefs.setString('saved_characters', dataString);
  }

  // ------------------------------------------

  void addCharacter(Character newChar) {
    _characters.add(newChar);
    saveData(); // <--- SALVA ORA
    notifyListeners();
  }

  void removeCharacter(int index) {
    _characters.removeAt(index);
    saveData(); // <--- SALVA ORA
    notifyListeners();
  }

  // Il metodo dummy lo teniamo per test, ma ora salva anche lui!
  void addDummyCharacter() {
    _characters.add(Character(
      name: "Eroe Test ${_characters.length + 1}",
      charClass: "Guerriero",
      level: 1,
      strength: 16,
    ));
    saveData();
    notifyListeners();
  }

  void updateCharacter(Character char) {
    // Poiché 'char' è un riferimento all'oggetto nella lista,
    // modificarlo modifica anche la lista. Dobbiamo solo salvare su disco.
    saveData();
    notifyListeners();
  }

  // Metodo Export PDF (Invariato)
  Future<void> exportCharacterPdf(Character char) async {
    try {
      String strMod = char.getModifier(char.strength);
      String dexMod = char.getModifier(char.dexterity);

      Map<String, String> dataMap = {
        'CharacterName': char.name,
        'CharacterName 2': char.name,
        'ClassLevel': '${char.charClass} ${char.level}',
        'PlayerName': 'Giocatore',
        'Race ': char.race,
        'Background': char.background, // Ora salviamo anche questo!

        'STR': char.strength.toString(),
        'DEX': char.dexterity.toString(),
        'STRmod': strMod,
        'DEXmod': dexMod,

        'HPMax': char.hpMax.toString(),
        'HPCurrent': char.hpMax.toString(),
      };

      final fileName = 'scheda_${char.name.replaceAll(' ', '_')}';
      final file = await _pdfService.fillPDF(dataMap, fileName);

      await OpenFile.open(file.path);

    } catch (e) {
      print("Errore export: $e");
    }
  }
}