import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';

class CharacterEditorScreen extends StatefulWidget {
  const CharacterEditorScreen({super.key});

  @override
  State<CharacterEditorScreen> createState() => _CharacterEditorScreenState();
}

class _CharacterEditorScreenState extends State<CharacterEditorScreen>
    with SingleTickerProviderStateMixin {
  // Controller per le Tab (5 schede)
  late TabController _tabController;

  // --- STATO DEL PERSONAGGIO (Dati Temporanei) ---
  // Tab 1: Anagrafica
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _raceCtrl = TextEditingController(text: "Umano");
  final TextEditingController _classCtrl = TextEditingController(
    text: "Guerriero",
  );
  final TextEditingController _backgroundCtrl = TextEditingController();
  final TextEditingController _physicalCtrl =
      TextEditingController(); // Occhi, capelli, ecc.

  // Tab 2: Statistiche (Default 10)
  int _str = 10;
  int _dex = 10;
  int _con = 10;
  int _int = 10;
  int _wis = 10;
  int _cha = 10;

  // Tab 3: Traits & Skills
  final TextEditingController _traitsCtrl = TextEditingController();

  // Tab 4: Inventario (Lista semplice di stringhe per ora)
  List<String> _inventory = [];

  // Tab 5: Spells
  List<String> _spells = [];

  @override
  void initState() {
    super.initState();
    // Inizializza il controller per 5 schede
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _raceCtrl.dispose();
    _classCtrl.dispose();
    _backgroundCtrl.dispose();
    _physicalCtrl.dispose();
    _traitsCtrl.dispose();
    super.dispose();
  }

  void _saveCharacter() {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Manca il nome dell'eroe!")));
      return;
    }

    // Creazione oggetto Character
    final newChar = Character(
      name: _nameCtrl.text,
      charClass: _classCtrl.text,
      race: _raceCtrl.text,
      background: _backgroundCtrl.text,
      physicalTraits: _physicalCtrl.text,
      level: 1, // Default lvl 1
      strength: _str,
      dexterity: _dex,
      constitution: _con,
      intelligence: _int,
      wisdom: _wis,
      charisma: _cha,
      hpMax: 10 + ((_con - 10) ~/ 2), // Calcolo HP base
      // Nota: Dovrai espandere il modello Character per salvare anche inventory, spells e traits
    );

    // Salvataggio nel Provider
    Provider.of<CharacterProvider>(
      context,
      listen: false,
    ).addCharacter(newChar);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor Personaggio"),
        actions: [
          // Tasto SALVA sempre visibile in alto a destra
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Salva Personaggio",
            onPressed: _saveCharacter,
          ),
        ],
        // LA TUA TOP BAR DI NAVIGAZIONE
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Permette di scrollare se le tab sono tante
          indicatorColor: Colors.redAccent,
          tabs: const [
            Tab(text: "Anagrafica", icon: Icon(Icons.person)),
            Tab(text: "Stats", icon: Icon(Icons.bar_chart)),
            Tab(text: "Abilità", icon: Icon(Icons.psychology)),
            Tab(text: "Oggetti", icon: Icon(Icons.backpack)),
            Tab(text: "Magia", icon: Icon(Icons.auto_fix_high)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBioTab(),
          _buildStatsTab(),
          _buildTraitsTab(),
          _buildInventoryTab(),
          _buildSpellsTab(),
        ],
      ),
    );
  }

  // --- SCHEDA 1: ANAGRAFICA ---
  Widget _buildBioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _customTextField("Nome Eroe", _nameCtrl),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _customTextField("Razza", _raceCtrl)),
              const SizedBox(width: 10),
              Expanded(child: _customTextField("Classe", _classCtrl)),
            ],
          ),
          const SizedBox(height: 10),

          // PRIMA: Tratti Somatici (Breve descrizione)
          _customTextField(
            "Tratti Fisici (Occhi, capelli, altezza...)",
            _physicalCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 10),

          // POI: Background (Testo lungo per la storia)
          // Impostiamo maxLines a 10 (o null per infinito) per dare spazio alla creatività
          _customTextField(
            "Background / Storia del personaggio",
            _backgroundCtrl,
            maxLines: 10, // Molto spazio verticale!
          ),
        ],
      ),
    );
  }

  // --- SCHEDA 2: STATISTICHE ---
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Bottone futuro per i dadi
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Simulatore Dadi: Coming Soon!")),
              );
            },
            icon: const Icon(Icons.casino), // Icona Dado
            label: const Text("Tira Statistiche (Simulazione)"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
          ),
          const Divider(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _statCounter("FORZA", _str, (v) => setState(() => _str = v)),
              _statCounter("DESTREZZA", _dex, (v) => setState(() => _dex = v)),
              _statCounter(
                "COSTITUZIONE",
                _con,
                (v) => setState(() => _con = v),
              ),
              _statCounter(
                "INTELLIGENZA",
                _int,
                (v) => setState(() => _int = v),
              ),
              _statCounter("SAGGEZZA", _wis, (v) => setState(() => _wis = v)),
              _statCounter("CARISMA", _cha, (v) => setState(() => _cha = v)),
            ],
          ),
        ],
      ),
    );
  }

  // --- SCHEDA 3: TRAITS / ABILITÀ ---
  Widget _buildTraitsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Tratti e Competenze",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TextField(
              controller: _traitsCtrl,
              maxLines: null, // Espandibile all'infinito
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText:
                    "Scrivi qui i privilegi di classe, talenti o note sulle abilità...",
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SCHEDA 4: OGGETTI ---
  Widget _buildInventoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // Dialogo rapido per aggiungere oggetto
              _showAddItemDialog(
                (item) => setState(() => _inventory.add(item)),
              );
            },
            child: const Text("+ Aggiungi Oggetto"),
          ),
        ),
        Expanded(
          child: _inventory.isEmpty
              ? const Center(
                  child: Text(
                    "Zaino vuoto",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _inventory.length,
                  itemBuilder: (ctx, i) => ListTile(
                    leading: const Icon(Icons.backpack_outlined),
                    title: Text(_inventory[i]),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => setState(() => _inventory.removeAt(i)),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // --- SCHEDA 5: SPELL (Placeholder) ---
  Widget _buildSpellsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_fix_high, size: 60, color: Colors.purpleAccent),
          const SizedBox(height: 20),
          const Text("Grimorio Incantesimi", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Qui implementerai la ricerca API Open5e"),
                ),
              );
            },
            child: const Text("Cerca nell'API"),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS (Per non ripetere codice) ---

  Widget _customTextField(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black12,
      ),
    );
  }

  Widget _statCounter(String label, int value, Function(int) onChange) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => onChange(value > 1 ? value - 1 : 1),
              ),
              Text(
                "$value",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => onChange(value < 30 ? value + 1 : 30),
              ),
            ],
          ),
          // Mostra il modificatore piccolo sotto
          Text(
            "MOD: ${(value - 10) ~/ 2 >= 0 ? '+' : ''}${(value - 10) ~/ 2}",
            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(Function(String) onAdd) {
    String tempItem = "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nuovo Oggetto"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: "Es. Spada Lunga"),
          onChanged: (v) => tempItem = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          TextButton(
            onPressed: () {
              if (tempItem.isNotEmpty) onAdd(tempItem);
              Navigator.pop(ctx);
            },
            child: const Text("Aggiungi"),
          ),
        ],
      ),
    );
  }
}
