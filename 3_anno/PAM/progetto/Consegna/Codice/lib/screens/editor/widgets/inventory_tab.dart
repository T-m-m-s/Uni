import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';

class InventoryTab extends StatelessWidget {
  const InventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);

    return editor.inventory.isEmpty
        ? const Center(child: Text("Backpack is empty", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: editor.inventory.length,
      itemBuilder: (ctx, i) => Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.backpack_outlined, color: Colors.redAccent),
          title: Text(editor.inventory[i].name),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => editor.removeFromInventory(i),
          ),
        ),
      ),
    );
  }
}
