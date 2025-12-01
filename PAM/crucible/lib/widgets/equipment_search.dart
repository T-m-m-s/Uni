import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dnd_api_services.dart';

class EquipmentSearch extends StatefulWidget {
  const EquipmentSearch({super.key});

  @override
  State<EquipmentSearch> createState() => _EquipmentSearchDialogState();
}

class _EquipmentSearchDialogState extends State<EquipmentSearch> {
  final DndApiService _apiService = DndApiService();
  List<dynamic> _results = [];
  bool _isLoading = false;
  final TextEditingController _searchCtrl = TextEditingController();

  // Variabile per il Timer del Debounce
  Timer? _debounce;

  @override
  void dispose() {
    // Importante: distruggere il timer se chiudi il dialogo mentre scrivi
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Questa funzione viene chiamata ad ogni lettera digitata
  void _onSearchChanged(String query) {
    // 1. Se c'è un timer attivo, cancellalo (l'utente sta ancora scrivendo)
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // 2. Fai partire un nuovo timer di 500 millisecondi
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // 3. Se passano 500ms senza nuove lettere, lancia la ricerca
      _doSearch(query);
    });
  }

  void _doSearch(String query) async {
    if (query.length < 3) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // Chiamata API vera
    final results = await _apiService.searchEquipment(query);

    // Controllo se il widget è ancora montato (per evitare errori se chiudi il dialog)
    if (!mounted) return;

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cerca nell'Armeria"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // CAMPO DI TESTO DINAMICO
            TextField(
              controller: _searchCtrl,
              autofocus: true, // Apre la tastiera subito
              decoration: const InputDecoration(
                labelText: "Inizia a scrivere...",
                hintText: "Es. Sword, Shield...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // Qui sta la magia: onChanged chiama la nostra logica debounce
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 10),

            // LISTA RISULTATI
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.keyboard, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Scrivi almeno 3 lettere per cercare", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, index) {
                  final item = _results[index];
                  return ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item['damage_dice'] ?? ''} ${item['damage_type'] ?? ''}"),
                    trailing: const Icon(Icons.add_circle_outline, color: Colors.redAccent),
                    onTap: () {
                      // Formatta la stringa per l'inventario
                      String resultString = item['name'];
                      if (item['damage_dice'] != null) {
                        resultString += " (${item['damage_dice']} ${item['damage_type']})";
                      }
                      Navigator.pop(context, resultString);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Chiudi"),
        ),
      ],
    );
  }
}