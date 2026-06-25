import 'package:flutter/material.dart';
import '../models/character.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? initialNote;
  final String heroName;

  const NoteEditorScreen({super.key, this.initialNote, required this.heroName});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteCategory _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? "");
    _contentController = TextEditingController(text: widget.initialNote?.content ?? "");
    _category = widget.initialNote?.category ?? NoteCategory.general;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final note = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
    );
    Navigator.pop(context, note);
  }

  String _getCategoryName(NoteCategory cat) {
    switch (cat) {
      case NoteCategory.characters: return "Characters";
      case NoteCategory.locations: return "Locations";
      case NoteCategory.quests: return "Quests";
      case NoteCategory.general: return "General";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialNote == null ? "New Note" : "Edit Note"),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("SAVE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bar per la categoria
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: NoteCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getCategoryName(cat)),
                      selected: isSelected,
                      selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                      onSelected: (val) {
                        if (val) setState(() => _category = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: "Note title",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(height: 32),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                      decoration: const InputDecoration(
                        hintText: "Start writing...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
