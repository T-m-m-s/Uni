import 'dart:io';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../core/constants/app_assets.dart';

class PdfService {
  // Metodo generico: prende una Mappa di dati (NomeCampo: Valore) e riempie il PDF
  Future<File> fillPDF(Map<String, String> formData, String fileName) async {
    // 1. Carica il template
    final ByteData data = await rootBundle.load(
      AppAssets.dndSheet,
    );
    final List<int> bytes = data.buffer.asUint8List();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    // 2. Itera sulla MAPPA dei tuoi dati (es. 'CharacterName': 'Grog')
    formData.forEach((fieldName, value) {
      // 3. Cerca il campo nel PDF in modo SICURO (Fix per l'errore getByName)

      // All'interno di fillPDF, dopo aver ottenuto 'form'
      final PdfForm form = document.form;

      try {
        for (int i = 0; i < form.fields.count; i++) {
          final PdfField field = form.fields[i];

          // Se il nome del campo nel PDF corrisponde alla chiave della tua Mappa
          if (field.name == fieldName) {
            if (field is PdfTextBoxField) {
              field.text = value;
            } else if (field is PdfCheckBoxField) {
              // Gestione checkbox (opzionale, se serve)
              field.isChecked = value.toLowerCase() == 'true';
            }
            break; // Trovato, passiamo al prossimo dato
          }
        }
      } catch (e) {
        print("Errore nel riempire il campo $fieldName: $e");
      }
    });

    // 4. (Opzionale) Rendi il PDF non modificabile
    // document.form.flattenAllFields();

    // 5. Salva il file
    final List<int> savedBytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName.pdf';
    final file = File(path);
    await file.writeAsBytes(savedBytes);

    return file;
  }
}
