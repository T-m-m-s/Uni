import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import 'character_editor.dart';
import 'character_sheet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharacterProvider>(context);
    final characters = provider.characters;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUCIBLE"),
        leading: const Icon(Icons.shield_outlined),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),

      body: characters.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_edu, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            const Text("Nessun eroe nel registro.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            const Text("Premi + per forgiare una nuova leggenda.", style: TextStyle(fontSize: 14, color: Colors.white38)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final char = characters[index];

          // Rimuoviamo il Dismissible (Swipe) per usare solo il tasto cestino più sicuro
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.redAccent.withOpacity(0.2),
                child: Text(
                  char.charClass.isNotEmpty ? char.charClass[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("${char.charClass} • Lvl ${char.level}"),

              // --- ZONA PULSANTI (STAMPA & ELIMINA) ---
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                children: [
                  // Tasto STAMPA
                  IconButton(
                    icon: const Icon(Icons.print, color: Colors.white70),
                    tooltip: "Stampa PDF",
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Forgiatura PDF per ${char.name}...")),
                      );
                      await provider.exportCharacterPdf(char);
                    },
                  ),

                  // Tasto ELIMINA con POPUP
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "Elimina Eroe",
                    onPressed: () {
                      _showDeleteConfirmation(context, provider, index, char.name);
                    },
                  ),
                ],
              ),
              onTap: () {
                // APRIAMO LA SCHEDA DETTAGLIATA
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterSheetScreen(character: char),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CharacterEditorScreen()),
          );
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NUOVO EROE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- FUNZIONE PER IL POPUP DI CONFERMA ---
  void _showDeleteConfirmation(BuildContext context, CharacterProvider provider, int index, String charName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Elimina Eroe"),
        content: Text("Sei sicuro di voler eliminare per sempre $charName?\nQuesta azione è irreversibile."),
        actions: [
          // Tasto ANNULLA
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Chiude il popup
            child: const Text("Annulla", style: TextStyle(color: Colors.grey)),
          ),
          // Tasto ELIMINA
          TextButton(
            onPressed: () {
              // 1. Cancella dal provider (che salva automaticamente su disco)
              provider.removeCharacter(index);
              // 2. Chiude il popup
              Navigator.pop(ctx);
              // 3. Feedback visuale
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Personaggio eliminato dal registro.")),
              );
            },
            child: const Text("ELIMINA", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}