import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';
import '../../../widgets/race_search.dart';
import '../../../widgets/class_search.dart';
import '../../../widgets/background_search.dart';
import '../../../widgets/subclass_search.dart';
import 'editor_shared_widgets.dart';

class BioTab extends StatelessWidget {
  const BioTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    void selectRace() async {
      final Map<String, dynamic>? selected = await RaceSearch.showRaceSearch(context);
      if (selected != null) {
        editor.selectRace(selected);
      }
    }

    void selectClass() async {
      final Map<String, dynamic>? selected = await ClassSearch.showClassSearch(context);
      if (selected != null) {
        editor.selectClass(selected);
      }
    }

    void selectSubclass() async {
      final Map<String, dynamic>? selected = await SubclassSearch.showSubclassSearch(context, editor.classCtrl.text);
      if (selected != null) {
        editor.selectSubclass(selected);
      }
    }

    void selectBackground() async {
      final Map<String, dynamic>? selected = await BackgroundSearch.showBackgroundSearch(context);
      if (selected != null) {
        editor.selectBackground(selected);
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LIVE PREVIEW ---
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLiveStat("MAX HP", "${editor.currentMaxHp}", Icons.favorite, scale),
                _buildLiveStat("HIT DIE", editor.classData?['hit_dice'] ?? "1d8", Icons.casino, scale),
                _buildLiveStat("CURRENT AC", "${editor.currentBaseAc}", Icons.shield, scale),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),

          Row(
            children: [
              Expanded(flex: 3, child: EditorSharedWidgets.customTextField("Hero Name", editor.nameCtrl)),
              SizedBox(width: 10 * scale),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LEVEL", style: TextStyle(fontSize: 10 * scale, color: Colors.grey)),
                    Row(
                      children: [
                        IconButton(onPressed: () => editor.setLevel(editor.level > 1 ? editor.level - 1 : 1), icon: Icon(Icons.remove, size: 16 * scale)),
                        Text("${editor.level}", style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            int newLevel = editor.level < 20 ? editor.level + 1 : 20;
                            editor.setLevel(newLevel);
                          }, 
                          icon: Icon(Icons.add, size: 16 * scale)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            children: [
              Expanded(child: EditorSharedWidgets.interactiveTextField("Race", editor.raceCtrl, selectRace)),
              SizedBox(width: 10 * scale),
              Expanded(child: EditorSharedWidgets.interactiveTextField("Class", editor.classCtrl, selectClass)),
            ],
          ),
          if (editor.level >= 3) ...[
            SizedBox(height: 16 * scale),
            EditorSharedWidgets.interactiveTextField("Subclass", editor.subclassCtrl, selectSubclass),
          ],
          SizedBox(height: 20 * scale),
          EditorSharedWidgets.interactiveTextField("Background", editor.backgroundCtrl, selectBackground),
          
          if (editor.allowedBackgroundStats.isNotEmpty) ...[
            SizedBox(height: 20 * scale),
            Text(
              "STAT BONUSES (2024 BACKGROUND)",
              style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 8 * scale),
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: editor.allowedBackgroundStats.map((stat) {
                final currentBonus = editor.selectedBgBonuses[stat] ?? 0;
                return ChoiceChip(
                  label: Text("$stat +$currentBonus", style: TextStyle(fontSize: 14 * scale)),
                  selected: currentBonus > 0,
                  selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                  onSelected: (selected) {
                    // Semplice ciclo: 0 -> +2 -> +1 -> 0
                    int nextBonus = 0;
                    if (currentBonus == 0) {
                      nextBonus = 2;
                    } else if (currentBonus == 2) {
                      nextBonus = 1;
                    }
                    
                    editor.applyManualBonus(stat, nextBonus);
                  },
                );
              }).toList(),
            ),
            Text(
              "Choose +2/+1 or +1/+1/+1 among the options above.",
              style: TextStyle(fontSize: 11 * scale, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],

          SizedBox(height: 20 * scale),
          const Divider(color: Colors.white24),
          SizedBox(height: 20 * scale),
          EditorSharedWidgets.customTextField("Physical Traits", editor.physicalCtrl, maxLines: 3),
          SizedBox(height: 10 * scale),
          SwitchListTile(
            title: Text("Custom Mode", style: TextStyle(fontSize: 16 * scale)),
            subtitle: Text("Ignore spell level limits.", style: TextStyle(fontSize: 14 * scale)),
            value: editor.customMode,
            activeThumbColor: Colors.redAccent,
            onChanged: (val) => editor.setCustomMode(val),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStat(String label, String value, IconData icon, double scale) {
    return Column(
      children: [
        Icon(icon, color: Colors.redAccent, size: 20 * scale),
        SizedBox(height: 4 * scale),
        Text(value, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 9 * scale, color: Colors.grey, letterSpacing: 0.5)),
      ],
    );
  }
}
