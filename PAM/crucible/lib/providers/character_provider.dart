import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart'; // Assicurati che questo import ci sia
import '../models/character.dart';
import '../services/pdf_service.dart';

class CharacterProvider with ChangeNotifier {
  // 1. LA LISTA DEI PERSONAGGI
  final List<Character> _characters = [];
  final PdfService _pdfService = PdfService();

  // Getter per leggere la lista
  List<Character> get characters => _characters;

  // --- METODO MANCANTE (AGGIUNTO ORA) ---
  // Questo è il metodo che il tuo Editor sta cercando di chiamare
  void addCharacter(Character newChar) {
    _characters.add(newChar);
    notifyListeners(); // Avvisa la UI di aggiornarsi
  }
  // --------------------------------------

  // Metodo per rimuovere un personaggio
  void removeCharacter(int index) {
    _characters.removeAt(index);
    notifyListeners();
  }

  // Metodo Test: Aggiunge un personaggio finto
  void addDummyCharacter() {
    _characters.add(
      Character(
        name: "Eroe Test ${_characters.length + 1}",
        charClass: "Guerriero",
        level: 1,
        strength: 16,
      ),
    );
    notifyListeners();
  }

  // Metodo Export PDF
  Future<void> exportCharacterPdf(Character char) async {
    try {
      // Calcoli preliminari (es. modificatori)
      String strMod = char.getModifier(char.strength);
      String dexMod = char.getModifier(char.dexterity);

      // Mappatura Dati
      Map<String, String> dataMap = {
        'CharacterName': char.name,
        'CharacterName 2': char.name,
        'ClassLevel': '${char.charClass} ${char.level}',
        'PlayerName': 'Giocatore',
        'Race ': char.race, // Ora usiamo la razza vera dell'oggetto

        'STR': char.strength.toString(),
        'DEX': char.dexterity.toString(),
        'STRmod': strMod,
        'DEXmod': dexMod,

        // Esempi di valori fissi (da collegare al modello in futuro)
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
