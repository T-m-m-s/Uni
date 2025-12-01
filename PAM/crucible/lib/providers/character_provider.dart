import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart'; // Assicurati di avere questo import
import '../models/character.dart';
import '../services/pdf_service.dart';

class CharacterProvider with ChangeNotifier {
  Character _character = Character();
  final PdfService _pdfService = PdfService();

  Character get character => _character;

  void updateName(String newName) {
    _character.name = newName;
    notifyListeners();
  }

  void updateStrength(String val) {
    _character.strength = int.tryParse(val) ?? 10;
    notifyListeners();
  }

  // Funzione Export aggiornata
  Future<void> exportPdf() async {
    try {
      // 1. Creiamo la Mappa qui! (Mapping Model -> PDF Fields)
      Map<String, String> dataMap = {
        'CharacterName': _character.name,
        'ClassLevel': '${_character.charClass} ${_character.level}',
        'STR': _character.strength.toString(),
        'DEX': _character.dexterity.toString(),
        'STRmod': _character.getModifier(_character.strength),
        'DEXmod': _character.getModifier(_character.dexterity),
        // Aggiungi qui altri campi man mano che espandi l'app
      };

      // 2. Chiamiamo il servizio generico
      final file = await _pdfService.fillPDF(
          dataMap,
          'scheda_${_character.name.replaceAll(' ', '_')}' // Nome file dinamico
      );

      // 3. Apri il file
      await OpenFile.open(file.path);

    } catch (e) {
      print("Errore export: $e");
    }
  }
}