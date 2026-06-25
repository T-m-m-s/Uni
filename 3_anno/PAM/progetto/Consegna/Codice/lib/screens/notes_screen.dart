import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  final Character character;

  const NotesScreen({super.key, required this.character});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  NoteCategory? _selectedFilter;

  void _addNote() async {
    final Note? newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(heroName: widget.character.name),
      ),
    );
    
    if (newNote != null && (newNote.title.isNotEmpty || newNote.content.isNotEmpty)) {
      setState(() {
        widget.character.notes.add(newNote);
      });
      _save();
    }
  }

  void _editNote(int index) async {
    final Note? editedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          initialNote: widget.character.notes[index],
          heroName: widget.character.name,
        ),
      ),
    );

    if (editedNote != null) {
      setState(() {
        widget.character.notes[index] = editedNote;
      });
      _save();
    }
  }

  void _deleteNote(int index) {
    setState(() {
      widget.character.notes.removeAt(index);
    });
    _save();
  }

  void _save() {
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(widget.character);
  }

  // Rimozione del vecchio _showNoteEditor dialog

  String _getCategoryName(NoteCategory cat) {
    switch (cat) {
      case NoteCategory.characters: return "Characters";
      case NoteCategory.locations: return "Locations";
      case NoteCategory.quests: return "Quests";
      case NoteCategory.general: return "General";
    }
  }

  IconData _getCategoryIcon(NoteCategory cat) {
    switch (cat) {
      case NoteCategory.characters: return Icons.person_outline;
      case NoteCategory.locations: return Icons.map_outlined;
      case NoteCategory.quests: return Icons.flag_outlined;
      case NoteCategory.general: return Icons.note_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredNotes = _selectedFilter == null 
        ? widget.character.notes 
        : widget.character.notes.where((n) => n.category == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes: ${widget.character.name}"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text("All"),
                  selected: _selectedFilter == null,
                  selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                  onSelected: (val) => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                ...NoteCategory.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getCategoryName(cat)),
                    selected: _selectedFilter == cat,
                    selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                    onSelected: (val) => setState(() => _selectedFilter = val ? cat : null),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: filteredNotes.isEmpty
          ? Center(
              child: Text(
                _selectedFilter == null ? "No notes for this hero." : "No notes in this category.",
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                final actualIndex = widget.character.notes.indexOf(note);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                      child: Icon(_getCategoryIcon(note.category), color: Colors.redAccent),
                    ),
                    title: Text(
                      note.title.isEmpty ? "Untitled" : note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteNote(actualIndex),
                    ),
                    onTap: () => _editNote(actualIndex),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("ADD NOTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
