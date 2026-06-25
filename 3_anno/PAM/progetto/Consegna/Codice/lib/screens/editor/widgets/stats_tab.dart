import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/editor_provider.dart';
import 'editor_shared_widgets.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final editor = Provider.of<EditorProvider>(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        children: [
          // Method Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (editor.customMode) _methodChip(context, "Manual", "Manual", editor),
                _methodChip(context, "Standard", "Standard", editor),
                _methodChip(context, "Points", "PointBuy", editor),
                _methodChip(context, "Dice", "Dice", editor),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          
          if (editor.statMethod == "PointBuy") ...[
            Text(
              "POINTS REMAINING: ${editor.pointBuyPool}",
              style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 10 * scale),
          ],

          if (editor.statMethod == "Dice") ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => editor.setStatMethod("Dice"),
                  icon: const Icon(Icons.casino),
                  label: const Text("Roll Again"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                ),
                SizedBox(width: 16 * scale),
                Text(
                  "Pool: ${editor.diceResults.join(', ')}",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14 * scale),
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
          ],

          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10 * scale,
                crossAxisSpacing: 10 * scale,
                childAspectRatio: 1.0,
                children: [
                  _buildStatWidget("STRENGTH", editor),
                  _buildStatWidget("DEXTERITY", editor),
                  _buildStatWidget("CONSTITUTION", editor),
                  _buildStatWidget("INTELLIGENCE", editor),
                  _buildStatWidget("WISDOM", editor),
                  _buildStatWidget("CHARISMA", editor),
                ],
              );
            },
          ),
          SizedBox(height: 24 * scale),

          // Combat Summary Section
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white10),
            ),
            child: _buildCombatGrid(editor, context),
          ),
        ],
      ),
    );
  }

  Widget _buildCombatGrid(EditorProvider editor, BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    List<Widget> items = [
      _buildCombatStat("PROF", "+${editor.proficiencyBonus}", Icons.military_tech, context),
      _buildCombatStat("INIT", (editor.initiative >= 0 ? "+${editor.initiative}" : "${editor.initiative}"), Icons.timer, context),
      _buildCombatStat("SPEED", "${editor.speed}ft", Icons.directions_run, context),
      _buildCombatStat("MELEE ATK", "+${editor.meleeHit}", Icons.colorize, context),
      _buildCombatStat("RANGED ATK", "+${editor.rangedHit}", Icons.gps_fixed, context),
      _buildCombatStat("HIT DICE", editor.hitDice, Icons.casino, context),
    ];

    if (editor.isSpellcaster) {
      items.add(_buildCombatStat("MAGIC ATK", "+${editor.spellAttackBonus}", Icons.auto_fix_high, context));
      items.add(_buildCombatStat("SPELL DC", "${editor.spellSaveDc}", Icons.gavel, context));
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10 * scale,
        mainAxisSpacing: 20 * scale,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _methodChip(BuildContext context, String label, String value, EditorProvider editor) {
    final isSelected = editor.statMethod == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.redAccent.withValues(alpha: 0.8),
        onSelected: (selected) {
          if (selected) editor.setStatMethod(value);
        },
      ),
    );
  }

  Widget _buildStatWidget(String label, EditorProvider editor) {
    if (editor.statMethod == "Manual") {
      return EditorSharedWidgets.statCounter(label, editor.getStatValue(label), (v) => editor.setStat(label, v));
    } else if (editor.statMethod == "PointBuy") {
      return EditorSharedWidgets.statCounterPointBuy(label, editor.getStatValue(label), (v) => editor.setStat(label, v));
    } else {
      // Standard Array or Dice
      final pool = editor.statMethod == "Standard" ? editor.standardArray : editor.diceResults;
      return EditorSharedWidgets.statSelector(
        label, 
        editor.assignedIndices[label], 
        pool, 
        editor.assignedIndices,
        (v) => editor.assignStat(label, v)
      );
    }
  }

  Widget _buildCombatStat(String label, String value, IconData icon, BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white70, size: 20 * scale),
              SizedBox(width: 4 * scale),
              Text(value, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        ),
        SizedBox(height: 2 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(fontSize: 11 * scale, color: Colors.grey, letterSpacing: 0.5)),
        ),
      ],
    );
  }
}
