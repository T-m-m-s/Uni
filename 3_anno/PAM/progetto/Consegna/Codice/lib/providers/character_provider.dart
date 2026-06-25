import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../services/pdf_service.dart';
import '../services/mappers/pdf_mapper.dart';

class CharacterProvider with ChangeNotifier {
  List<Character> _characters = [];
  final PdfService _pdfService = PdfService();

  List<Character> get characters => _characters;

  CharacterProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('saved_characters');

    if (dataString != null) {
      final List<dynamic> jsonList = json.decode(dataString);
      _characters = jsonList.map((jsonItem) => Character.fromJson(jsonItem)).toList();
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = json.encode(_characters.map((e) => e.toJson()).toList());
    await prefs.setString('saved_characters', dataString);
  }
  
  void addCharacter(Character newChar) {
    _characters.add(newChar);
    saveData();
    notifyListeners();
  }

  void removeCharacter(int index) {
    _characters.removeAt(index);
    saveData();
    notifyListeners();
  }

  void updateCharacter(Character char) {
    saveData();
    notifyListeners();
  }

  Future<void> exportCharacterPdf(Character char) async {
    try {
      final Map<String, String> dataMap = PdfMapper.mapCharacterToPdf(char);
      final fileName = 'sheet_${char.name.replaceAll(' ', '_')}';
      final file = await _pdfService.fillPDF(dataMap, fileName);
      await OpenFile.open(file.path);
    } catch (e) {
      debugPrint("Error exporting PDF: $e");
    }
  }
}
