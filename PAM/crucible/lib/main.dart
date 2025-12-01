import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa i tuoi file creati in precedenza
import 'providers/character_provider.dart';
import 'services/dnd_api_services.dart';

void main() {
  // Configurazione iniziale di Flutter
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // WRAPPER PROVIDER:
    // Avvolgiamo l'intera app nel ChangeNotifierProvider.
    // Questo rende lo stato del personaggio accessibile ovunque nell'app.
    ChangeNotifierProvider(
      create: (context) => CharacterProvider(),
      child: const CrucibleApp(),
    ),
  );
}

class CrucibleApp extends StatelessWidget {
  const CrucibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crucible D&D',
      // Un tema scuro, adatto al nome "Crucible" e al gaming
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.black12,
        ),
      ),
      home: const TestBenchScreen(),
    );
  }
}

class TestBenchScreen extends StatefulWidget {
  const TestBenchScreen({super.key});

  @override
  State<TestBenchScreen> createState() => _TestBenchScreenState();
}

class _TestBenchScreenState extends State<TestBenchScreen> {
  // Istanziamo il servizio API direttamente qui per il test rapido
  final DndApiService _apiService = DndApiService();

  // Controller per vedere i log della ricerca a video (solo per debug)
  String _apiLog = "Cerca una spell per vedere i risultati qui...";

  @override
  Widget build(BuildContext context) {
    // Accesso allo stato tramite Provider
    final charProvider = Provider.of<CharacterProvider>(context);
    final char = charProvider.character;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crucible: Test Bench'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Esporta PDF',
            onPressed: () async {
              // TEST EXPORT PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generazione PDF in corso...')),
              );
              await charProvider.exportPdf();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Dati Personaggio (Provider Test)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),

            // CAMPO NOME
            TextField(
              decoration: const InputDecoration(labelText: 'Nome Personaggio'),
              onChanged: (value) => charProvider.updateName(value),
              // Pre-fill se c'è già un valore
              controller: TextEditingController(text: char.name)..selection = TextSelection.fromPosition(TextPosition(offset: char.name.length)),
            ),
            const SizedBox(height: 10),

            // CAMPO FORZA (con calcolo automatico modificatore)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Forza (STR)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => charProvider.updateStrength(value),
                    controller: TextEditingController(text: char.strength.toString()),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text("MOD", style: TextStyle(fontSize: 10)),
                      // Qui leggiamo il modificatore calcolato dalla logica del modello
                      Text(
                        char.getModifier(char.strength),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const Divider(height: 40),

            const Text(
              "2. API Integration Test (Open5e)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),

            // CAMPO RICERCA SPELL
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cerca incantesimo (es. "fire")',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) async {
                setState(() => _apiLog = "Ricerca in corso...");
                try {
                  final results = await _apiService.searchSpells(value);
                  setState(() {
                    if (results.isEmpty) {
                      _apiLog = "Nessun risultato trovato.";
                    } else {
                      // Prende i primi 3 risultati per testare
                      _apiLog = "Trovati: ${results.length}\n";
                      for (var spell in results.take(3)) {
                        _apiLog += "- ${spell['name']} (Lvl ${spell['level']})\n";
                      }
                    }
                  });
                } catch (e) {
                  setState(() => _apiLog = "Errore: $e");
                }
              },
            ),

            const SizedBox(height: 10),

            // BOX RISULTATI API
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.black26,
              child: Text(
                _apiLog,
                style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
              ),
            ),

            const Divider(height: 40),

            const Text(
              "3. PDF Output Preview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
            const SizedBox(height: 5),
            const Text(
              "Compila i campi sopra e premi l'icona della stampante in alto a destra. Se tutto funziona, il PDF ufficiale si aprirà con i dati inseriti.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
