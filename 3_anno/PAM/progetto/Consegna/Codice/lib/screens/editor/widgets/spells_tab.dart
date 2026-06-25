import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';

class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);

    return editor.spells.isEmpty
        ? const Center(child: Text("Grimoire is empty", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: editor.spells.length,
      itemBuilder: (ctx, i) => Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.auto_fix_high, color: Colors.redAccent),
          title: Text(editor.spells[i].name),
          subtitle: Text("Lvl ${editor.spells[i].level}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => editor.removeFromSpells(i),
          ),
        ),
      ),
    );
  }
}
