import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';
import '../widgets/equipment_search.dart';

class CharacterSheetScreen extends StatefulWidget {
  final Character character;

  const CharacterSheetScreen({super.key, required this.character});

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Usiamo Consumer per assicurarci che la UI si aggiorni se cambiano i dati
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.character.name),
            actions: [
              // TASTO LEVEL UP (Futuro)
              IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.amber),
                tooltip: "Level Up!",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Meccanica Level Up: In arrivo!"))
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.redAccent,
              tabs: const [
                Tab(text: "Stats"),
                Tab(text: "Bio"),
                Tab(text: "Zaino"),
                Tab(text: "Magia"),
              ],
            ),
          ),
          body: Column(
            children: [
              _buildHeader(widget.character),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatsTab(widget.character),
                    _buildBioTab(widget.character),
                    _buildListTab(widget.character, "Oggetto", true), // True = Inventory
                    _buildListTab(widget.character, "Incantesimo", false), // False = Spells
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- HEADER: HP e Info Rapide ---
  Widget _buildHeader(Character char) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.redAccent,
            child: Text(char.charClass[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${char.race} ${char.charClass}", style: const TextStyle(color: Colors.white70)),
                Text("Livello ${char.level}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            children: [
              const Text("HP", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              Text("${char.hpMax}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  // --- TAB 1: STATISTICHE ---
  Widget _buildStatsTab(Character char) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 15, runSpacing: 15,
        alignment: WrapAlignment.center,
        children: [
          _statBox("FOR", char.strength, char.getModifier(char.strength)),
          _statBox("DES", char.dexterity, char.getModifier(char.dexterity)),
          _statBox("COS", char.constitution, char.getModifier(char.constitution)),
          _statBox("INT", char.intelligence, char.getModifier(char.intelligence)),
          _statBox("SAG", char.wisdom, char.getModifier(char.wisdom)),
          _statBox("CAR", char.charisma, char.getModifier(char.charisma)),
        ],
      ),
    );
  }

  Widget _statBox(String label, int value, String mod) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(mod, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("($value)", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- TAB 2: BIO ---
  Widget _buildBioTab(Character char) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard("Tratti Fisici", char.physicalTraits),
        _infoCard("Background", char.background),
      ],
    );
  }

  Widget _infoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const Divider(),
            Text(content.isEmpty ? "Nessuna informazione." : content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // --- TAB 3 & 4: LISTA GENERICA (Inventario / Spell) ---
  Widget _buildListTab(Character char, String itemType, bool isInventory) {
    // Seleziona la lista giusta
    List<String> items = isInventory ? char.inventory : char.spells;

    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? Center(child: Text("Nessun $itemType aggiunto."))
              : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(isInventory ? Icons.backpack : Icons.auto_fix_high),
                title: Text(items[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    // Rimuovi e Salva
                    setState(() { items.removeAt(index); });
                    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddDialog(context, char, isInventory, items);
            },
            icon: const Icon(Icons.add),
            label: Text("Aggiungi $itemType"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, Character char, bool isInventory, List<String> list) async {

    // CASO 1: INVENTARIO (Usa la nuova ricerca API)
    if (isInventory) {
      // Mostriamo il dialogo avanzato e attendiamo il risultato
      final String? selectedItem = await showDialog<String>(
        context: context,
        builder: (ctx) => const EquipmentSearch(),
      );

      // Se l'utente ha selezionato qualcosa (non è null)
      if (selectedItem != null) {
        list.add(selectedItem);
        Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
      }

    } else {
      // CASO 2: SPELL / GENERICO (Usa il vecchio input manuale per ora)
      // (Nota: Puoi creare un 'SpellSearchDialog' simile per fare la stessa cosa con le magie!)
      String tempValue = "";
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Nuovo Incantesimo"), // Testo specifico
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "Nome..."),
            onChanged: (v) => tempValue = v,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            TextButton(
              onPressed: () {
                if (tempValue.isNotEmpty) {
                  list.add(tempValue);
                  Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                }
                Navigator.pop(ctx);
              },
              child: const Text("Salva"),
            ),
          ],
        ),
      );
    }
  }
}