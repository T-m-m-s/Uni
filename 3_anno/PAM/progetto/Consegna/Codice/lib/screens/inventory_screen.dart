import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';
import '../widgets/objects_search.dart';
import '../core/utils/rules_engine.dart';

class InventoryScreen extends StatefulWidget {
  final Character character;

  const InventoryScreen({super.key, required this.character});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _canEquipItem(Character char, DndItem newItem) {
    String? error = RulesEngine.canEquipItem(char.equipped.map((e) => e.name).toList(), newItem.name);
    if (error != null) {
      _showError(error);
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        final char = widget.character;
        return Scaffold(
          appBar: AppBar(
            title: Text("${char.name}'s Inventory"),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddEquipmentMenu(context, char),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Item", style: TextStyle(color: Colors.white)),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildSectionHeader("CURRENT EQUIPMENT", Icons.shield),
              if (char.equipped.isEmpty) _buildEmptyState("No items equipped"),
              ...char.equipped.map((item) => _buildItemTile(context, char, item, true)),

              _buildSectionHeader("BACKPACK", Icons.backpack),
              if (char.inventory.isEmpty) _buildEmptyState("The backpack is empty"),
              ...char.inventory.map((item) => _buildItemTile(context, char, item, false)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white.withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white24, fontStyle: FontStyle.italic))),
    );
  }

  Widget _buildItemTile(BuildContext context, Character char, DndItem item, bool isPrimaryList) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      color: isPrimaryList ? Colors.grey[800] : Colors.grey[900],
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale),
        leading: IconButton(
          icon: Icon(
            isPrimaryList ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isPrimaryList ? Colors.redAccent : Colors.grey,
            size: 24 * scale,
          ),
          onPressed: () => _toggleEquipStatus(char, item, isPrimaryList),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: isPrimaryList ? FontWeight.bold : FontWeight.normal,
            color: isPrimaryList ? Colors.white : Colors.white70,
          ),
        ),
        onTap: () => _showItemInfo(context, item),
        onLongPress: () => _showDeleteItemDialog(context, char, item, isPrimaryList),
      ),
    );
  }

  void _toggleEquipStatus(Character char, DndItem item, bool isCurrentlyEquipped) {
    setState(() {
      if (isCurrentlyEquipped) {
        char.equipped.remove(item);
        char.inventory.add(item);
      } else {
        if (_canEquipItem(char, item)) {
          char.inventory.remove(item);
          char.equipped.add(item);
        }
      }
    });
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
  }

  void _showDeleteItemDialog(BuildContext context, Character char, DndItem item, bool isEquipped) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text("Are you sure you want to remove '${item.name}' from your inventory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isEquipped) {
                  char.equipped.remove(item);
                } else {
                  char.inventory.remove(item);
                }
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showItemInfo(BuildContext context, DndItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Text(item.desc.isEmpty ? "No detailed information available." : item.desc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  void _showAddEquipmentMenu(BuildContext context, Character char) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add to Inventory", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionBtn(ctx, Icons.colorize, "Weapon", Colors.redAccent, () async {
                  final res = await ObjectsSearch.showWeaponSearch(context);
                  if (res != null) _addItem(char, res);
                }),
                _buildActionBtn(ctx, Icons.shield, "Armor", Colors.redAccent, () async {
                  final res = await ObjectsSearch.showArmorSearch(context);
                  if (res != null) _addItem(char, res);
                }),
                _buildActionBtn(ctx, Icons.auto_awesome, "Item", Colors.redAccent, () async {
                  final res = await ObjectsSearch.showMagicItemSearch(context);
                  if (res != null) _addItem(char, res);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  void _addItem(Character char, DndItem item) {
    setState(() {
      char.inventory.add(item);
    });
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
  }
}
