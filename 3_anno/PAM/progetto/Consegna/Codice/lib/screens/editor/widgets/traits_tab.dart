import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';

class TraitsTab extends StatelessWidget {
  const TraitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    if (editor.isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final classFeatures = _getClassFeaturesForLevel(editor);
    final subclassFeatures = _getSubclassFeaturesForLevel(editor);

    return Padding(
      padding: EdgeInsets.all(16 * scale),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editor.backgroundFeat != null)
              _featSection(context, "ORIGIN FEAT", editor.backgroundFeat!, Icons.stars, Colors.redAccent, scale),
            
            if (editor.raceFeat != null && editor.raceFeat!.isNotEmpty)
              _featSection(context, "RACIAL TRAITS", editor.raceFeat!, Icons.fingerprint, Colors.redAccent, scale),

            if (subclassFeatures.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 12 * scale, left: 4 * scale),
                child: Text(
                  "SUBCLASS FEATURES (${editor.subclassCtrl.text})",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * scale,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...subclassFeatures.map((f) => _featSection(
                context, 
                f['name']!.toUpperCase(), 
                f['desc']!, 
                Icons.workspace_premium, 
                Colors.redAccent,
                scale,
              )),
            ],

            if (classFeatures.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(top: 8 * scale, bottom: 12 * scale, left: 4 * scale),
                child: Text(
                  "CLASS FEATURES (Lvl ${editor.level})",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * scale,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...classFeatures.map((f) => _featSection(
                context, 
                f['name']!.toUpperCase(), 
                f['desc']!, 
                Icons.security, 
                Colors.redAccent,
                scale,
                showUses: true,
                level: editor.level,
              )),
            ],

            Padding(
              padding: EdgeInsets.only(top: 8 * scale, bottom: 12 * scale, left: 4 * scale),
              child: Text(
                "OTHER FEATS AND NOTES",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12 * scale,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            TextField(
              controller: editor.traitsCtrl,
              maxLines: 8,
              autofocus: false,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(fontSize: 14 * scale),
              decoration: InputDecoration(
                hintText: "Add other feats or notes here...",
                fillColor: isDark ? Colors.black12 : Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                  borderSide: isDark ? const BorderSide(color: Colors.white10) : BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            SizedBox(height: 80 * scale),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getClassFeaturesForLevel(EditorProvider editor) {
    if (editor.classData == null) return [];
    final table = editor.classData!['table'] ?? "";
    final desc = editor.classData!['desc'] ?? "";
    if (table is! String || table.isEmpty) return [];

    final lines = table.split('\n');
    final Map<int, List<String>> featuresByLevel = {};
    for (var line in lines) {
      if (!line.contains('|')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 4) continue;
      final levelStr = parts[1].replaceAll(RegExp(r'\D'), '');
      if (levelStr.isEmpty) continue;
      final level = int.tryParse(levelStr);
      if (level == null) continue;
      final featuresPart = parts[3];
      if (featuresPart.toLowerCase().contains("proficiency bonus") || featuresPart == 'Features' || featuresPart == '---') continue;
      final names = featuresPart.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty && f != '-').toList();
      featuresByLevel[level] = names;
    }

    final List<Map<String, String>> results = [];
    for (int l = 1; l <= editor.level; l++) {
      if (featuresByLevel.containsKey(l)) {
        for (var name in featuresByLevel[l]!) {
          results.add({'name': name, 'desc': _extractDesc(name, desc)});
        }
      }
    }
    return results;
  }

  String _extractDesc(String name, String fullDesc) {
    final headers = ["### $name", "#### $name", "**$name.**", "**$name**"];
    for (var header in headers) {
      if (fullDesc.contains(header)) {
        final start = fullDesc.indexOf(header) + header.length;
        int nextHeader = fullDesc.indexOf('###', start);
        if (nextHeader == -1) nextHeader = fullDesc.indexOf('####', start);
        if (nextHeader == -1) {
          final regExp = RegExp(r'\n\s*\*\*');
          final match = regExp.firstMatch(fullDesc.substring(start));
          if (match != null) nextHeader = start + match.start;
        }
        if (nextHeader != -1) return fullDesc.substring(start, nextHeader).trim();
        return fullDesc.substring(start).trim();
      }
    }
    return "Details not found.";
  }

  List<Map<String, String>> _getSubclassFeaturesForLevel(EditorProvider editor) {
    if (editor.subclassFeat == null || editor.subclassFeat!.isEmpty) return [];
    
    final fullDesc = editor.subclassFeat!;
    final List<Map<String, String>> results = [];
    
    // Pattern common in Open5e subclass descriptions: ### Feature Name
    final regExp = RegExp(r'### (.*?)\n');
    final matches = regExp.allMatches(fullDesc).toList();
    
    for (int i = 0; i < matches.length; i++) {
      final name = matches[i].group(1)?.trim() ?? "";
      if (name.isEmpty) continue;
      
      final start = matches[i].end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : fullDesc.length;
      final content = fullDesc.substring(start, end).trim();
      
      // Heuristic to check if this feature is available at current level
      // Often says "At 3rd level", "Starting at 7th level", etc.
      if (_isFeatureAvailableAtLevel(content, editor.level)) {
        results.add({'name': name, 'desc': content});
      }
    }
    
    // If we couldn't parse specific features, just show the whole thing as one
    if (results.isEmpty && fullDesc.isNotEmpty) {
      results.add({'name': 'Subclass Description', 'desc': fullDesc});
    }
    
    return results;
  }

  bool _isFeatureAvailableAtLevel(String desc, int currentLevel) {
    final lower = desc.toLowerCase();
    // Patterns: "At 3rd level", "Starting at 7th level", "When you reach 10th level", "Prerequisite: 15th level"
    final levelMatch = RegExp(r'(?:at|starting at|reach|prerequisite:)\s+(\d+)(?:st|nd|rd|th)\s+level').firstMatch(lower);
    if (levelMatch != null) {
      final featLevel = int.tryParse(levelMatch.group(1) ?? "0");
      if (featLevel != null && featLevel > currentLevel) return false;
    }
    return true;
  }

  String? _getUsesInfo(String name, int level) {
    final n = name.toUpperCase();
    if (n.contains("RAGE")) {
      if (level < 3) return "2 uses";
      if (level < 6) return "3 uses";
      if (level < 12) return "4 uses";
      if (level < 17) return "5 uses";
      if (level < 20) return "6 uses";
      return "Unlimited";
    }
    if (n.contains("CHANNEL DIVINITY")) {
      if (level < 6) return "1 use";
      if (level < 18) return "2 uses";
      return "3 uses";
    }
    if (n.contains("WILD SHAPE")) {
      if (level < 20) return "2 uses";
      return "Unlimited";
    }
    if (n.contains("KI POINTS")) return "$level points";
    if (n.contains("SORCERY POINTS")) return "$level points";
    if (n.contains("UNARMORED DEFENSE")) return "Active";
    if (n.contains("SECOND WIND")) return "1 use";
    if (n.contains("ACTION SURGE")) {
      if (level < 17) return "1 use";
      return "2 uses";
    }
    if (n.contains("SNEAK ATTACK")) {
      int dice = ((level + 1) / 2).floor();
      return "${dice}d6";
    }
    return null;
  }

  Widget _featSection(BuildContext context, String title, String content, IconData icon, Color color, double scale, {bool showUses = false, int level = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Resource tracking
    final uses = showUses ? _getUsesInfo(title, level) : null;

    // Table & Markdown Cleanup
    String cleanContent = content;
    if (cleanContent.contains('|')) {
      final lines = cleanContent.split('\n');
      final newLines = <String>[];
      for (var line in lines) {
        if (line.contains('|') && !line.contains('---')) {
          final cells = line.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
          if (cells.isNotEmpty) newLines.add("• " + cells.join(": "));
        } else if (!line.contains('|')) {
          newLines.add(line);
        }
      }
      cleanContent = newLines.join('\n');
    }

    cleanContent = cleanContent
        .replaceAll(RegExp(r'\*\*_(.*?)_\*\*'), r'$1')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'_(.*?)_'), r'$1')
        .replaceAll(RegExp(r'###'), '')
        .replaceAll(RegExp(r'\$1'), '')
        .trim();

    return Container(
      margin: EdgeInsets.only(bottom: 16 * scale),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.15)),
        boxShadow: isDark ? null : [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8 * scale, offset: Offset(0, 4 * scale))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * scale),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4 * scale, color: color),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(icon, color: color, size: 16 * scale),
                              SizedBox(width: 8 * scale),
                              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11 * scale)),
                            ],
                          ),
                          if (uses != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10 * scale)),
                              child: Text(uses, style: TextStyle(color: color, fontSize: 9 * scale, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      SizedBox(height: 8 * scale),
                      Text(cleanContent, style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87, fontSize: 14 * scale, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
