import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

class SpellSearch extends StatefulWidget {
  final int characterLevel;
  final String className; // La classe del personaggio (es. "Cleric")
  final bool customMode;

  const SpellSearch({
    super.key,
    required this.characterLevel,
    required this.className,
    required this.customMode
  });

  @override
  State<SpellSearch> createState() => _SpellSearchDialogState();
}

class _SpellSearchDialogState extends State<SpellSearch> {
  final DndApiService _apiService = DndApiService();

  List<dynamic> _allSpells = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSpells();
  }

  void _loadAllSpells() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    // Recupera la lista GIGANTE scaricata nello Splash Screen (dalla cache)
    var spells = await _apiService.getAllSpells();

    if (!extensionsEnabled) {
      spells = spells.where((s) => s['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;

    setState(() {
      _allSpells = spells;
      _filterList(""); // Applica subito il filtro classe
      _isLoading = false;
    });
  }

  // Helper per capire il livello
  int _getSpellLevel(dynamic spell) {
    if (spell['level_int'] != null) return spell['level_int'];
    String levelStr = spell['level'].toString().toLowerCase();
    if (levelStr.contains("cantrip")) return 0;
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(levelStr);
    return match != null ? int.parse(match.group(0)!) : 99;
  }

  void _filterList(String query) {
    // Calcolo del livello massimo (se non siamo in custom mode)
    int maxSpellLevel = (widget.characterLevel + 1) ~/ 2;
    final lowerQuery = query.toLowerCase();

    // Normalizziamo la classe del PG per il confronto tramite il servizio API
    String searchClass = _apiService.getClassSlug(widget.className);

    setState(() {
      _filteredResults = _allSpells.where((spell) {
        // 1. Filtro Testo (Nome Spell)
        final name = spell['name'].toString().toLowerCase();
        bool matchesName = name.contains(lowerQuery);

        // 2. Level Filter
        int spellLvl = _getSpellLevel(spell);
        // If customMode is TRUE, ignore the level limit
        bool matchesLevel = widget.customMode || (spellLvl <= maxSpellLevel);

        // 3. CLASS FILTER
        // The API has a 'dnd_class' field like: "Bard, Sorcerer, Wizard"
        String spellClasses = spell['dnd_class']?.toString().toLowerCase() ?? "";

        // KEY LOGIC:
        // If widget.customMode is TRUE -> matchesClass becomes TRUE automatically (logical OR).
        // If FALSE -> Check if spellClasses contains your character's class.
        bool matchesClass = widget.customMode || spellClasses.contains(searchClass);

        // The spell passes only if it matches Name AND Level AND Class
        return matchesName && matchesLevel && matchesClass;
      }).toList();

      // Sorting: First by Level, then Alphabetically
      _filteredResults.sort((a, b) {
        int lvlA = _getSpellLevel(a);
        int lvlB = _getSpellLevel(b);
        if (lvlA != lvlB) return lvlA.compareTo(lvlB);
        return a['name'].compareTo(b['name']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int maxLvl = (widget.characterLevel + 1) ~/ 2;

    return AlertDialog(
      // TITOLO DINAMICO: Cambia per far capire all'utente cosa sta vedendo
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              widget.customMode
                  ? "Grimorio Universale"  // Titolo se Custom
                  : "Grimorio ${widget.className}" // Titolo se Normale
          ),
          Text(
            widget.customMode
                ? "Tutte le classi & livelli sbloccati"
                : "Solo ${widget.className} (Max Lvl $maxLvl)",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: const InputDecoration(
                labelText: "Cerca incantesimo...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterList,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.customMode
                        ? "No spells found with this name."
                        : "No spells found for ${widget.className}.\n\nActivate 'Custom Mode' to see spells from other classes.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ListView.separated(
                itemCount: _filteredResults.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, index) {
                  final item = _filteredResults[index];

                  // Mostriamo anche le classi dell'incantesimo se siamo in custom mode
                  // so the user knows what they are taking
                  String subtitle = "Lvl ${item['level']}";
                  if (widget.customMode) {
                    subtitle += " • ${item['dnd_class']}"; // e.g., "Lvl 3 • Wizard, Sorcerer"
                  }

                  return ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])
                    ),
                    trailing: const Icon(Icons.add_circle_outline, color: Colors.purpleAccent),
                    onTap: () {
                      final spell = Spell(
                        name: item['name'],
                        level: item['level'].toString(),
                        desc: item['desc'] ?? '',
                      );
                      Navigator.pop(context, spell);
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