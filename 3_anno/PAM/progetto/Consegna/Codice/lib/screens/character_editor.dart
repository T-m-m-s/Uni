import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';
import '../providers/editor_provider.dart';
import '../widgets/objects_search.dart';
import '../widgets/spell_search.dart';
import 'editor/widgets/bio_tab.dart';
import 'editor/widgets/stats_tab.dart';
import 'editor/widgets/skills_tab.dart';
import 'editor/widgets/traits_tab.dart';
import 'editor/widgets/inventory_tab.dart';
import 'editor/widgets/spells_tab.dart';

class CharacterEditorScreen extends StatelessWidget {
  const CharacterEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorProvider(),
      child: const _CharacterEditorContent(),
    );
  }
}

class _CharacterEditorContent extends StatefulWidget {
  const _CharacterEditorContent();

  @override
  State<_CharacterEditorContent> createState() => _CharacterEditorContentState();
}

class _CharacterEditorContentState extends State<_CharacterEditorContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Async initialization of default data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditorProvider>(context, listen: false).initDefaults();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveCharacter(BuildContext context, EditorProvider editor) {
    if (editor.nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing hero name!")));
      return;
    }

    final newChar = editor.createCharacter();
    Provider.of<CharacterProvider>(context, listen: false).addCharacter(newChar);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);

    return Scaffold(
      floatingActionButton: _buildEditorFab(editor),
      appBar: AppBar(
        title: const Text("Hero Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Save",
            onPressed: () => _saveCharacter(context, editor),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BioTab(),
          StatsTab(),
          SkillsTab(),
          TraitsTab(),
          InventoryTab(),
          SpellsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        child: SafeArea(
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: Colors.redAccent,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Bio", icon: Icon(Icons.person, size: 16)),
              Tab(text: "Stats", icon: Icon(Icons.bar_chart, size: 16)),
              Tab(text: "Skills", icon: Icon(Icons.psychology, size: 16)),
              Tab(text: "Traits", icon: Icon(Icons.auto_fix_normal, size: 16)),
              Tab(text: "Pack", icon: Icon(Icons.backpack, size: 16)),
              Tab(text: "Magic", icon: Icon(Icons.auto_fix_high, size: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildEditorFab(EditorProvider editor) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        if (_tabController.index == 4) {
          return FloatingActionButton.extended(
            onPressed: () => _addEquipmentMenu(context, editor),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add", style: TextStyle(color: Colors.white)),
          );
        } else if (_tabController.index == 5) {
          return FloatingActionButton.extended(
            onPressed: () => _addSpellMenu(context, editor),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.auto_fix_high, color: Colors.white),
            label: const Text("Add", style: TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _addEquipmentMenu(BuildContext context, EditorProvider editor) {
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
                  if (res != null) editor.addToInventory(res);
                }),
                _buildActionBtn(ctx, Icons.shield, "Armor", Colors.redAccent, () async {
                  final res = await ObjectsSearch.showArmorSearch(context);
                  if (res != null) editor.addToInventory(res);
                }),
                _buildActionBtn(ctx, Icons.auto_awesome, "Item", Colors.redAccent, () async {
                  final res = await ObjectsSearch.showMagicItemSearch(context);
                  if (res != null) editor.addToInventory(res);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _addSpellMenu(BuildContext context, EditorProvider editor) async {
    String currentClass = editor.classCtrl.text;
    List<String> nonCasters = ['barbarian', 'fighter', 'monk', 'rogue'];

    if (nonCasters.contains(currentClass.toLowerCase()) && !editor.customMode) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This class does not have access to magic."),
            backgroundColor: Colors.redAccent,
          )
      );
      return;
    }

    final Spell? selectedSpell = await showDialog<Spell>(
      context: context,
      builder: (ctx) => SpellSearch(
          characterLevel: editor.level,
          className: currentClass,
          customMode: editor.customMode
      ),
    );

    if (selectedSpell != null) editor.addToSpells(selectedSpell);
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
}
