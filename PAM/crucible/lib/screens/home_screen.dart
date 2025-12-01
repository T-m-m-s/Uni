import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import 'character_editor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colleghiamo la UI al Provider
    final provider = Provider.of<CharacterProvider>(context);
    final characters = provider.characters;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUCIBLE"),
        leading: const Icon(Icons.shield_outlined),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implementare impostazioni
            },
          ),
        ],
      ),

      body: characters.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.history_edu,
                    size: 80,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nessun eroe nel registro.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Premi + per forgiare una nuova leggenda.",
                    style: TextStyle(fontSize: 14, color: Colors.white38),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final char = characters[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red[900],
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    provider.removeCharacter(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${char.name} è stato cancellato."),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        child: Text(
                          char.charClass.isNotEmpty
                              ? char.charClass[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        char.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("${char.charClass} • Livello ${char.level}"),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.black45,
                            color: Colors.greenAccent[400],
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),

                      // --- INIZIO MODIFICA: IL TASTO STAMPA È QUI ---
                      trailing: IconButton(
                        icon: const Icon(Icons.print, color: Colors.white70),
                        tooltip: "Stampa Scheda PDF",
                        onPressed: () async {
                          // Feedback visivo (Messaggio in basso)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Forgiatura PDF per ${char.name}...",
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );

                          // Chiama la funzione di export nel provider
                          await provider.exportCharacterPdf(char);
                        },
                      ),

                      // --- FINE MODIFICA ---
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Apro dettagli di ${char.name}..."),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            // Cambia la destinazione qui:
            MaterialPageRoute(
              builder: (context) => const CharacterEditorScreen(),
            ),
          );
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "NUOVO EROE",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
