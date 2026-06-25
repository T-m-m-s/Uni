import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crucible/models/dnd_item.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

// Enum per capire cosa stiamo cercando
enum SearchCategory { weapon, armor, magicItem }

class ObjectsSearch extends StatefulWidget {
  final SearchCategory category;

  const ObjectsSearch({super.key, required this.category});

  // --- METODI STATICI PER CHIAMARE IL DIALOGO FACILMENTE ---

  // 1. Cerca ARMI
  static Future<DndItem?> showWeaponSearch(BuildContext context) {
    return showDialog<DndItem>(
      context: context,
      builder: (ctx) => const ObjectsSearch(category: SearchCategory.weapon),
    );
  }

  // 2. Cerca ARMATURE
  static Future<DndItem?> showArmorSearch(BuildContext context) {
    return showDialog<DndItem>(
      context: context,
      builder: (ctx) => const ObjectsSearch(category: SearchCategory.armor),
    );
  }

  // 3. Cerca OGGETTI MAGICI / GENERICI
  static Future<DndItem?> showMagicItemSearch(BuildContext context) {
    return showDialog<DndItem>(
      context: context,
      builder: (ctx) => const ObjectsSearch(category: SearchCategory.magicItem),
    );
  }

  @override
  State<ObjectsSearch> createState() => _ObjectsSearchState();
}

class _ObjectsSearchState extends State<ObjectsSearch> {
  final DndApiService _apiService = DndApiService();

  List<dynamic> _allItems = [];       // Dati completi
  List<dynamic> _filteredResults = []; // Dati filtrati
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carica i dati in base alla categoria richiesta
  void _loadData() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    List<dynamic> data = [];

    switch (widget.category) {
      case SearchCategory.weapon:
        data = await _apiService.getAllWeapons();
        break;
      case SearchCategory.armor:
        data = await _apiService.getAllArmor();
        break;
      case SearchCategory.magicItem:
        data = await _apiService.getAllMagicItems();
        break;
    }

    if (!extensionsEnabled) {
      data = data.where((item) => item['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;

    setState(() {
      _allItems = data;
      _filteredResults = data;
      _isLoading = false;
    });
  }

  // Filtro locale istantaneo
  void _filterList(String query) {
    if (query.isEmpty) {
      setState(() => _filteredResults = _allItems);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredResults = _allItems.where((item) {
        return item['name'].toString().toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  // Formatta il sottotitolo in base al tipo di oggetto
  String _getSubtitle(dynamic item) {
    if (widget.category == SearchCategory.weapon) {
      return "${item['damage_dice'] ?? ''} ${item['damage_type'] ?? ''} ${item['properties'] != null ? '• ${(item['properties'] as List).join(', ')}' : ''}";
    } else if (widget.category == SearchCategory.armor) {
      return "AC ${item['ac_string'] ?? '-'} • ${item['category'] ?? ''}";
    } else {
      return "${item['rarity'] ?? ''} • ${item['type'] ?? ''}";
    }
  }

  // Titolo del Dialogo
  String _getTitle() {
    switch (widget.category) {
      case SearchCategory.weapon: return "Armeria (Armi)";
      case SearchCategory.armor: return "Fabbro (Armature)";
      case SearchCategory.magicItem: return "Emporio Magico";
    }
  }

  // Icona
  IconData _getIcon() {
    switch (widget.category) {
      case SearchCategory.weapon: return Icons.colorize; // Spada stilizzata
      case SearchCategory.armor: return Icons.shield;
      case SearchCategory.magicItem: return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getIcon(), color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(_getTitle(), style: const TextStyle(fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: "Search ${widget.category.name}...",
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterList,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty
                  ? const Center(child: Text("No items found."))
                  : ListView.separated(
                itemCount: _filteredResults.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final item = _filteredResults[index];
                  return ListTile(
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      _getSubtitle(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.add, color: Colors.redAccent),
                    onTap: () {
                      // Build the final string to return
                      String displayName = item['name'];
                      String description = item['desc'] ?? '';

                      // Add details in parentheses
                      if (widget.category == SearchCategory.weapon) {
                        // Retrieve properties (e.g., Two-handed, Light, Finesse...)
                        List<dynamic> props = item['properties'] ?? [];
                        String details = "${item['damage_dice']} ${item['damage_type']}";

                        // IF the weapon is two-handed, we write it in the string!
                        if (props.contains("two-handed")) {
                          details += ", two-handed";
                        }

                        if (item['damage_dice'] != null) displayName += " ($details)";
                        
                        if (description.isEmpty) {
                          description = "Damage: ${item['damage_dice']} ${item['damage_type']}\nProperties: ${props.join(', ')}";
                        }
                      } else if (widget.category == SearchCategory.armor) {
                        // Retrieve the category (Light, Medium, Heavy, Shield)
                        String category = item['category'] ?? '';

                        // Build the string: "Studded Leather (AC 12, Light Armor)"
                        if (item['ac_string'] != null) {
                          displayName += " (AC ${item['ac_string']}, $category)";
                        }
                        
                        if (description.isEmpty) {
                          description = "AC: ${item['ac_string']}\nCategory: $category\nStrength Requirement: ${item['stealth_disadvantage'] == true ? 'Disadvantage on Stealth' : 'None'}";
                        }
                      }

                      Navigator.pop(context, DndItem(name: displayName, desc: description));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Chiudi")),
      ],
    );
  }
}