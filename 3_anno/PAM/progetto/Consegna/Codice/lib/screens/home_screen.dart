import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../core/constants/app_assets.dart';
import 'character_editor.dart';
import 'character_sheet_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharacterProvider>(context);
    final characters = provider.characters;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CRUCIBLE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: characters.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.logo, width: 140, height: 140),
            const SizedBox(height: 20),
            const Text("No heroes in the registry.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(
              "Press + to forge a new legend.", 
              style: TextStyle(
                fontSize: 14, 
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white38 
                    : Colors.black38
              )
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final char = characters[index];

          // Remove the Dismissible (Swipe) to use only the safer delete button
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                child: Text(
                  char.charClass.isNotEmpty ? char.charClass[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text("${char.subclass.isNotEmpty ? char.subclass : char.charClass} • Lvl ${char.level}"),

              // --- BUTTON ZONE (PRINT & DELETE) ---
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                children: [
                  // PRINT button
                  IconButton(
                    icon: Icon(
                      Icons.print, 
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.black54
                    ),
                    tooltip: "Print PDF",
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Forging PDF for ${char.name}...")),
                      );
                      await provider.exportCharacterPdf(char);
                    },
                  ),

                  // DELETE button with POPUP
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "Delete Hero",
                    onPressed: () {
                      _showDeleteConfirmation(context, provider, index, char.name);
                    },
                  ),
                ],
              ),
              onTap: () {
                // OPEN DETAILED SHEET
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CharacterSheetScreen(character: char),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CharacterEditorScreen()),
          );
        },
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("NEW HERO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- FUNCTION FOR THE CONFIRMATION POPUP ---
  void _showDeleteConfirmation(BuildContext context, CharacterProvider provider, int index, String charName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Hero"),
        content: Text("Are you sure you want to delete $charName forever?\nThis action is irreversible."),
        actions: [
          // CANCEL button
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Closes the popup
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          // DELETE button
          TextButton(
            onPressed: () {
              // 1. Delete from provider (which automatically saves to disk)
              provider.removeCharacter(index);
              // 2. Closes the popup
              Navigator.pop(ctx);
              // 3. Visual feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Character removed from the registry.")),
              );
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
