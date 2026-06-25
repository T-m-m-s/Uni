import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';
import '../widgets/objects_search.dart';
import '../widgets/spell_search.dart';
import '../widgets/subclass_search.dart';
import 'notes_screen.dart';
import 'inventory_screen.dart';
import '../core/utils/rules_engine.dart';

class CharacterSheetScreen extends StatefulWidget {
  final Character character;

  const CharacterSheetScreen({super.key, required this.character});

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _speedUnitIndex = 0; // 0: ft, 1: m, 2: squares

  @override
  void initState() {
    super.initState();
    final bool showMagic = widget.character.isSpellcaster;
    _tabController = TabController(
      length: showMagic ? 5 : 4,
      vsync: this,
      initialIndex: 2, // Stats is now at index 2
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return "Skills";
      case 1: return "Battle";
      case 2: return "Stats";
      case 3: return "Features";
      case 4: return "Magic";
      default: return widget.character.name;
    }
  }

  // --- EQUIPMENT VALIDATION LOGIC ---
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
  // ---------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<CharacterProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          drawer: _buildDrawer(context, widget.character),
          floatingActionButton: _buildFloatingActionButton(context, widget.character),
          appBar: AppBar(
            title: Text(_getTabTitle(_tabController.index)),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: "Note",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotesScreen(character: widget.character),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: SizedBox(
                width: double.infinity,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorColor: Colors.redAccent,
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 11),
                  tabs: [
                    const Tab(text: "Skills"),
                    const Tab(text: "Battle"),
                    const Tab(text: "Stats"),
                    const Tab(text: "Features"),
                    if (widget.character.isSpellcaster) const Tab(text: "Magic"),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              _buildHeader(widget.character),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSkillsTab(widget.character),
                    _buildBattleTab(widget.character),
                    _buildStatsTab(widget.character),
                    _buildTraitsTab(widget.character),
                    if (widget.character.isSpellcaster) _buildSplitSpellsTab(context, widget.character),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBattleTab(Character char) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);
    final bool isUnconscious = char.hpCurrent == 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white10),
            ),
            child: _buildCombatGrid(char),
          ),
          
          SizedBox(height: 24 * scale),
          Text("ATTACK ACTIONS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12 * scale, letterSpacing: 1.2)),
          SizedBox(height: 12 * scale),
          
          if (char.isSpellcaster) 
            Row(
              children: [
                Expanded(
                  child: _buildBattleActionCard(
                    title: "Attack",
                    subtitle: "Weapon",
                    icon: Icons.colorize,
                    color: Colors.redAccent,
                    onTap: () => _showWeaponSelection(char),
                    scale: scale,
                    enabled: !isUnconscious,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildBattleActionCard(
                    title: "Spell",
                    subtitle: "Cast",
                    icon: Icons.auto_fix_high,
                    color: Colors.redAccent,
                    onTap: () => _showSpellSelection(char),
                    scale: scale,
                    enabled: !isUnconscious,
                  ),
                ),
              ],
            )
          else
            _buildBattleActionCard(
              title: "Weapon Attack",
              subtitle: "Use an equipped weapon",
              icon: Icons.colorize,
              color: Colors.redAccent,
              onTap: () => _showWeaponSelection(char),
              scale: scale,
              enabled: !isUnconscious,
            ),

          SizedBox(height: 12 * scale),
          Row(
            children: [
              Expanded(
                child: _buildBattleActionCard(
                  title: "Heal",
                  subtitle: "Restore HP",
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  onTap: () => _showHpDialog(char, true),
                  scale: scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _buildBattleActionCard(
                  title: "Damage",
                  subtitle: "Lose HP",
                  icon: Icons.heart_broken,
                  color: Colors.redAccent,
                  onTap: () => _showHpDialog(char, false),
                  scale: scale,
                  enabled: !isUnconscious,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24 * scale),
          Text("SAVING THROWS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12 * scale, letterSpacing: 1.2)),
          SizedBox(height: 12 * scale),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10 * scale,
            crossAxisSpacing: 10 * scale,
            childAspectRatio: 1.4,
            children: [
              _saveBtn("STR", char.strength, char, scale, enabled: !isUnconscious),
              _saveBtn("DEX", char.dexterity, char, scale, enabled: !isUnconscious),
              _saveBtn("CON", char.constitution, char, scale, enabled: !isUnconscious),
              _saveBtn("INT", char.intelligence, char, scale, enabled: !isUnconscious),
              _saveBtn("WIS", char.wisdom, char, scale, enabled: !isUnconscious),
              _saveBtn("CHA", char.charisma, char, scale, enabled: !isUnconscious),
            ],
          ),
        ],
      ),
    );
  }

  void _showHpDialog(Character char, bool isHeal) {
    final TextEditingController hpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isHeal ? "Heal Character" : "Take Damage"),
        content: TextField(
          controller: hpCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Amount",
            suffixText: "HP",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              int val = int.tryParse(hpCtrl.text) ?? 0;
              setState(() {
                if (isHeal) {
                  char.hpCurrent = (char.hpCurrent + val).clamp(0, char.hpMax);
                  if (char.hpCurrent > 0) {
                    char.deathSavesSuccess = 0;
                    char.deathSavesFailure = 0;
                  }
                } else {
                  char.hpCurrent = (char.hpCurrent - val).clamp(0, char.hpMax);
                }
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
              if (char.hpCurrent == 0) {
                _showDeathSavesDialog(char);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: isHeal ? Colors.green : Colors.red),
            child: Text(isHeal ? "HEAL" : "DAMAGE", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required double scale,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14 * scale, color: Colors.white)),
                    Text(subtitle, style: TextStyle(fontSize: 11 * scale, color: Colors.white70)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white24, size: 22 * scale),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeaponSelection(Character char) {
    // Better filter: must have a 'd' followed by a number for dice, and not be armor/shield
    final weapons = char.equipped.where((item) {
      final lower = item.name.toLowerCase();
      bool isNotArmor = !lower.contains("armor") && !lower.contains("shield");
      bool hasDice = RegExp(r'\d+d\d+').hasMatch(lower);
      return isNotArmor && hasDice;
    }).toList();

    if (weapons.isEmpty) {
      _showError("No weapons equipped!");
      return;
    }

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
            const Text("Select Weapon", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ...weapons.map((w) => ListTile(
              leading: const Icon(Icons.colorize, color: Colors.redAccent),
              title: Text(w.name, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _performWeaponAttack(char, w.name);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _performWeaponAttack(Character char, String weapon) {
    // Detect if it's ranged or melee (heuristic)
    bool isRanged = weapon.toLowerCase().contains("bow") || weapon.toLowerCase().contains("crossbow") || weapon.toLowerCase().contains("ranged");
    int bonus = isRanged ? char.rangedHit : char.meleeHit;
    
    // Extract dice (e.g. "1d8")
    final match = RegExp(r'(\d+d\d+)').firstMatch(weapon);
    String dice = match?.group(1) ?? "1d4";

    // Define state variables OUTSIDE the StatefulBuilder so they persist across rebuilds
    int? hitRoll;
    int? damageRoll;
    bool isCrit = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(weapon.split(' (')[0]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hitRoll == null)
                  ElevatedButton(
                    onPressed: () {
                      final d20 = (DateTime.now().microsecondsSinceEpoch % 20) + 1;
                      setDialogState(() {
                        hitRoll = d20;
                        isCrit = (d20 == 20);
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("ROLL TO HIT", style: TextStyle(color: Colors.white)),
                  )
                else
                  Column(
                    children: [
                      Text("Hit Result: ${hitRoll == 20 ? 'NAT 20!' : (hitRoll == 1 ? 'NAT 1!' : hitRoll! + bonus)}", 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (hitRoll != 20 && hitRoll != 1)
                        Text("(d20: $hitRoll + Bonus: $bonus)", style: const TextStyle(color: Colors.grey)),
                      if (isCrit) const Text("CRITICAL HIT!", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      if (damageRoll == null)
                        ElevatedButton(
                          onPressed: () {
                            setDialogState(() {
                              damageRoll = _rollDiceString(dice);
                              if (isCrit) {
                                // Add second die for crit
                                damageRoll = damageRoll! + _rollDiceString(dice);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          child: const Text("ROLL DAMAGE", style: TextStyle(color: Colors.white)),
                        )
                      else
                        Column(
                          children: [
                            Text("Damage: $damageRoll", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            Text("Type: ${weapon.contains(' ') ? weapon.split(' ').last.replaceAll(')', '') : 'Unknown'}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
            ],
          );
        },
      ),
    );
  }

  void _showSpellSelection(Character char) {
    if (char.preparedSpells.isEmpty) {
      _showError("No spells prepared!");
      return;
    }

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
            const Text("Select Spell", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: char.preparedSpells.map((s) => ListTile(
                  leading: const Icon(Icons.flash_on, color: Colors.purpleAccent),
                  title: Text(s.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(s.level == "0" ? "Cantrip" : "Level ${s.level}", style: const TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _performSpellAction(char, s);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSpellAction(Character char, Spell spell) {
    // Determine spell base level
    int baseLevel = 0;
    final levelRegex = RegExp(r'\d+');
    final levelMatch = levelRegex.firstMatch(spell.level);
    if (levelMatch != null) {
      baseLevel = int.tryParse(levelMatch.group(0)!) ?? 0;
    }

    // Try to find dice in description
    final match = RegExp(r'(\d+d\d+)').firstMatch(spell.desc);
    String? baseDice = match?.group(1);

    // Heuristic for attack vs other (save, utility, heal)
    bool isAttack = spell.desc.toLowerCase().contains("spell attack") || 
                    spell.desc.toLowerCase().contains("make a ranged attack");

    // Define persistent state for the dialog
    int selectedSlotLevel = baseLevel;
    int? hitRoll;
    int? effectRoll;
    bool casted = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final slots = char.getSpellSlots();
          final List<int> availableSlotLevels = [];
          if (baseLevel > 0) {
            for (int i = baseLevel; i <= 9; i++) {
              if (slots[i - 1] > 0) availableSlotLevels.add(i);
            }
          }

          bool canCast = true;
          if (baseLevel > 0) {
            int maxTotal = slots[selectedSlotLevel - 1];
            int used = char.usedSpellSlots[selectedSlotLevel] ?? 0;
            canCast = used < maxTotal;
          }

          // Calculate damage with upcasting (1 extra die per level above base usually)
          String currentDice = baseDice ?? "1d4";
          if (baseDice != null && selectedSlotLevel > baseLevel) {
            final diceParts = baseDice.split('d');
            int count = int.parse(diceParts[0]) + (selectedSlotLevel - baseLevel);
            currentDice = "${count}d${diceParts[1]}";
          }

          return AlertDialog(
            title: Text(spell.name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isAttack ? "SPELL ATTACK" : "SPELL EFFECT", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("Attack: +${char.spellAttackBonus} | DC: ${char.spellSaveDc}", 
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  
                  if (baseLevel > 0) ...[
                    const Text("Cast using level:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: availableSlotLevels.map((lvl) => ChoiceChip(
                        label: Text("Lvl $lvl"),
                        selected: selectedSlotLevel == lvl,
                        selectedColor: Colors.redAccent.withValues(alpha: 0.3),
                        onSelected: !casted ? (sel) {
                          if (sel) setDialogState(() => selectedSlotLevel = lvl);
                        } : null,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (isAttack) ...[
                    if (hitRoll == null)
                      ElevatedButton(
                        onPressed: canCast && !casted ? () {
                          final d20 = (DateTime.now().microsecondsSinceEpoch % 20) + 1;
                          setDialogState(() {
                            hitRoll = d20;
                            if (baseLevel > 0 && !casted) {
                              casted = true;
                              char.usedSpellSlots[selectedSlotLevel] = (char.usedSpellSlots[selectedSlotLevel] ?? 0) + 1;
                              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                            }
                          });
                        } : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: const Text("ROLL TO HIT", style: TextStyle(color: Colors.white)),
                      )
                    else
                      Column(
                        children: [
                          Text("Attack Result: ${hitRoll == 20 ? 'NAT 20!' : (hitRoll == 1 ? 'NAT 1!' : hitRoll! + char.spellAttackBonus)}", 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (hitRoll != 20 && hitRoll != 1)
                            Text("(d20: $hitRoll + Bonus: ${char.spellAttackBonus})", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                  ] else if (!casted && baseDice == null) ...[
                    ElevatedButton(
                      onPressed: canCast ? () {
                        setDialogState(() => casted = true);
                        if (baseLevel > 0) {
                          char.usedSpellSlots[selectedSlotLevel] = (char.usedSpellSlots[selectedSlotLevel] ?? 0) + 1;
                          Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text("CAST SPELL", style: TextStyle(color: Colors.white)),
                    ),
                  ],

                  if ((!isAttack || hitRoll != null) && baseDice != null) ...[
                    const SizedBox(height: 20),
                    if (effectRoll == null)
                      ElevatedButton(
                        onPressed: canCast || casted ? () {
                          setDialogState(() {
                            effectRoll = _rollDiceString(currentDice);
                            if (!casted && baseLevel > 0) {
                              casted = true;
                              char.usedSpellSlots[selectedSlotLevel] = (char.usedSpellSlots[selectedSlotLevel] ?? 0) + 1;
                              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                            }
                          });
                        } : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        child: Text("ROLL $currentDice", style: const TextStyle(color: Colors.white)),
                      )
                    else
                      Text("Result: $effectRoll", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                  
                  const SizedBox(height: 16),
                  if (!canCast && !casted) 
                    const Text("NO SLOTS REMAINING", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(spell.desc, style: const TextStyle(fontSize: 11, color: Colors.white60)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
            ],
          );
        },
      ),
    );
  }

  Widget _saveBtn(String label, int score, Character char, double scale, {bool enabled = true}) {
    final mod = char.getModifierValue(score);
    return InkWell(
      onTap: enabled ? () {
        final d20 = Random().nextInt(20) + 1;
        String res;
        if (d20 == 20) {
          res = "$label Save: NAT 20!";
        } else if (d20 == 1) {
          res = "$label Save: NAT 1!";
        } else {
          res = "$label Save: ${d20 + mod}";
        }
        
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(20 * scale),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      } : null,
      borderRadius: BorderRadius.circular(12 * scale),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14 * scale)),
              Text(mod >= 0 ? "+$mod" : "$mod", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18 * scale)),
            ],
          ),
        ),
      ),
    );
  }

  int _rollDiceString(String dice) {
    // Simple 1d8 parser
    final parts = dice.split('d');
    if (parts.length != 2) return 0;
    int count = int.tryParse(parts[0]) ?? 1;
    int sides = int.tryParse(parts[1]) ?? 4;
    int total = 0;
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < count; i++) {
      total += ((random + i) % sides) + 1;
    }
    return total;
  }

  // --- WIDGETS STRUTTURALI ---
  Widget _buildHeader(Character char) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Container(
      color: Colors.grey[900],
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      child: Row(
        children: [
          char.imagePath != null && char.imagePath!.isNotEmpty
              ? CircleAvatar(
                  radius: 24 * scale,
                  backgroundImage: char.imagePath!.startsWith('http')
                      ? NetworkImage(char.imagePath!)
                      : FileImage(File(char.imagePath!)) as ImageProvider,
                )
              : CircleAvatar(
                  radius: 24 * scale,
                  backgroundColor: Colors.redAccent,
                  child: FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(6 * scale),
                      child: Text(char.charClass.isNotEmpty ? char.charClass[0] : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    char.subclass.isNotEmpty ? "${char.race} ${char.charClass} (${char.subclass})" : "${char.race} ${char.charClass}",
                    style: TextStyle(color: Colors.white70, fontSize: 12 * scale),
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Level ${char.level}",
                            style: TextStyle(color: Colors.white, fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _headerStat("AC", "${char.armorClass}", Colors.greenAccent, scale),
          SizedBox(width: 12 * scale),
          _headerStat("HP", "${char.hpCurrent}/${char.hpMax}", Colors.redAccent, scale),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, Color color, double scale) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10 * scale)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildMagicSlotsSummary(Character char) {
    List<int> slots = char.getSpellSlots();
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Container(
      padding: EdgeInsets.all(12 * scale),
      margin: EdgeInsets.only(bottom: 16 * scale),
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SPELL SLOTS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 12 * scale)),
              TextButton(
                onPressed: () {
                  setState(() {
                    char.usedSpellSlots.clear();
                  });
                  Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                },
                child: Text("RESET ALL", style: TextStyle(fontSize: 10 * scale, color: Colors.redAccent)),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6 * scale,
              mainAxisSpacing: 6 * scale,
              childAspectRatio: 2.0,
            ),
            itemCount: slots.where((s) => s > 0).length,
            itemBuilder: (context, index) {
              List<MapEntry<int, int>> activeSlots = [];
              for (int i = 0; i < slots.length; i++) {
                if (slots[i] > 0) activeSlots.add(MapEntry(i + 1, slots[i]));
              }
              
              final entry = activeSlots[index];
              final used = char.usedSpellSlots[entry.key] ?? 0;
              final remaining = entry.value - used;

              return InkWell(
                onTap: () {
                  setState(() {
                    if (used < entry.value) {
                      char.usedSpellSlots[entry.key] = used + 1;
                    } else {
                      char.usedSpellSlots[entry.key] = 0;
                    }
                  });
                  Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: remaining > 0 ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6 * scale),
                    border: Border.all(color: remaining > 0 ? Colors.redAccent.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                        child: Text(
                          "Lvl ${entry.key}: $remaining/${entry.value}",
                          style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- LEVEL AND ASI ---
  void _levelUp(Character char) async {
    if (char.level >= 20) {
      _showError("Level 20 is the maximum level.");
      return;
    }

    setState(() {
      char.level++;
      // HP Recalculation (Base logic: half die + 1 + CON mod)
      int hitDie = 8;
      String cls = char.charClass.toLowerCase();
      if (cls.contains("fighter") || cls.contains("paladin") || cls.contains("ranger")) hitDie = 10;
      if (cls.contains("barbarian")) hitDie = 12;
      if (cls.contains("wizard") || cls.contains("sorcerer")) hitDie = 6;

      int hpGain = (hitDie ~/ 2) + 1 + char.getModifierValue(char.constitution);
      if (hpGain < 1) hpGain = 1;
      char.hpMax += hpGain;
    });

    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);

    // TRIGGER SUBCLASS SELECTION AT LEVEL 3
    if (char.level == 3 && char.subclass.isEmpty) {
      final Map<String, dynamic>? selected = await SubclassSearch.showSubclassSearch(context, char.charClass);
      if (!mounted) return;
      if (selected != null) {
        setState(() {
          char.subclass = selected['name'] ?? '';
          char.subclassFeat = selected['desc'] ?? '';
        });
        Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
      }
    }

    // Check ASI (Levels 4, 8, 12, 16, 19 + Extra for Fighter/Rogue)
    bool isAsiLevel = [4, 8, 12, 16, 19].contains(char.level);
    String cls = char.charClass.toLowerCase();
    if (cls.contains("fighter") && [6, 14].contains(char.level)) isAsiLevel = true;
    if (cls.contains("rogue") && char.level == 10) isAsiLevel = true;

    if (isAsiLevel) {
      await _showAsiPopup(char);
    }
  }

  Future<void> _showAsiPopup(Character char) async {
    int pointsAvailable = 2;
    Map<String, int> selectedIncreases = {
      'STR': 0, 'DEX': 0, 'CON': 0, 'INT': 0, 'WIS': 0, 'CHA': 0
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ability Score Improvement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("You reached level ${char.level}! Choose how to increase your stats (+2 in one or +1 in two).", 
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Text("Points remaining: $pointsAvailable", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 16),
              ...selectedIncreases.keys.map((stat) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stat, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: selectedIncreases[stat]! > 0 ? () {
                          setDialogState(() {
                            selectedIncreases[stat] = selectedIncreases[stat]! - 1;
                            pointsAvailable++;
                          });
                        } : null, 
                        icon: const Icon(Icons.remove_circle_outline)
                      ),
                      Text("${_getStatValue(char, stat) + selectedIncreases[stat]!}", style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: pointsAvailable > 0 && (_getStatValue(char, stat) + selectedIncreases[stat]!) < 20 ? () {
                          setDialogState(() {
                            selectedIncreases[stat] = selectedIncreases[stat]! + 1;
                            pointsAvailable--;
                          });
                        } : null, 
                        icon: const Icon(Icons.add_circle_outline)
                      ),
                    ],
                  )
                ],
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: pointsAvailable == 0 ? () {
                setState(() {
                  char.strength += selectedIncreases['STR']!;
                  char.dexterity += selectedIncreases['DEX']!;
                  char.constitution += selectedIncreases['CON']!;
                  char.intelligence += selectedIncreases['INT']!;
                  char.wisdom += selectedIncreases['WIS']!;
                  char.charisma += selectedIncreases['CHA']!;
                });
                Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                Navigator.pop(ctx);
              } : null,
              child: const Text("CONFIRM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            )
          ],
        ),
      ),
    );
  }

  int _getStatValue(Character char, String label) {
    switch(label) {
      case 'STR': return char.strength;
      case 'DEX': return char.dexterity;
      case 'CON': return char.constitution;
      case 'INT': return char.intelligence;
      case 'WIS': return char.wisdom;
      case 'CHA': return char.charisma;
      default: return 10;
    }
  }

  Widget _buildTraitsTab(Character char) {
    final List<Map<String, String>> classFeatures = _getClassFeaturesForLevel(char);
    final List<Map<String, String>> subclassFeatures = _getSubclassFeaturesForLevel(char);
    final List<Map<String, String>> raceFeatures = _getRaceFeatures(char);

    final List<Map<String, String>> allRace = [];
    if (char.originFeat.isNotEmpty) {
      allRace.add({'name': 'Origin Feat', 'desc': char.originFeat});
    }
    allRace.addAll(raceFeatures);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (allRace.isNotEmpty)
          _macroCategoryTile("RACE", allRace, Icons.fingerprint),
        
        if (classFeatures.isNotEmpty)
          _macroCategoryTile("CLASS", classFeatures, Icons.security),

        if (subclassFeatures.isNotEmpty)
          _macroCategoryTile("SUBCLASS", subclassFeatures, Icons.workspace_premium),
      ],
    );
  }

  Widget _macroCategoryTile(String title, List<Map<String, String>> features, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white10),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
        children: features.map((f) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _featCard(f['name']!, f['desc']!, icon, Colors.redAccent),
        )).toList(),
      ),
    );
  }

  List<Map<String, String>> _getRaceFeatures(Character char) {
    if (char.raceFeat.isEmpty) return [];
    return _parseFeaturesFromMarkdown(char.raceFeat, "${char.race} Details");
  }

  List<Map<String, String>> _getSubclassFeaturesForLevel(Character char) {
    if (char.subclassFeat.isEmpty) return [];
    final allSubclassFeatures = _parseFeaturesFromMarkdown(char.subclassFeat, "${char.subclass} Details");
    return allSubclassFeatures.where((f) => _isFeatureAvailableAtLevel(f['desc']!, char.level)).toList();
  }

  List<Map<String, String>> _parseFeaturesFromMarkdown(String fullDesc, String fallbackName) {
    final List<Map<String, String>> results = [];
    // Only split on 3 hashes to keep sub-features (4 hashes) within the same card
    final regExp = RegExp(r'### (.*?)\n');
    final matches = regExp.allMatches(fullDesc).toList();

    // Keywords to ignore (case-insensitive)
    final ignoredKeywords = [
      "proficiency", "equipment", "ability score improvement", 
      "arcane tradition", "spellcasting",
      "spellbook", "the book's appearance", "copying a spell", "replacing the book",
      "hit points"
    ];

    for (int i = 0; i < matches.length; i++) {
      final name = matches[i].group(1)?.trim() ?? "";
      if (name.isEmpty) continue;
      
      bool shouldIgnore = ignoredKeywords.any((k) => name.toLowerCase().contains(k.toLowerCase()));
      if (shouldIgnore) continue;

      final start = matches[i].end;
      final end = (i + 1 < matches.length) ? matches[i + 1].start : fullDesc.length;
      final content = fullDesc.substring(start, end).trim();
      results.add({'name': name, 'desc': content});
    }

    if (results.isEmpty && fullDesc.isNotEmpty) {
      // Check if the fallback content itself should be ignored
      bool shouldIgnoreFallback = ignoredKeywords.any((k) => fallbackName.toLowerCase().contains(k.toLowerCase()));
      if (!shouldIgnoreFallback) {
        results.add({'name': fallbackName, 'desc': fullDesc});
      }
    }
    return results;
  }

  List<Map<String, String>> _getClassFeaturesForLevel(Character char) {
    if (char.classFeat.isEmpty) return [];
    
    final List<Map<String, String>> allFeatures = _parseFeaturesFromMarkdown(char.classFeat, "${char.charClass} Details");
    return allFeatures.where((f) => _isFeatureAvailableAtLevel(f['desc']!, char.level)).toList();
  }

  bool _isFeatureAvailableAtLevel(String desc, int currentLevel) {
    final lower = desc.toLowerCase();
    
    // Patterns: "At 3rd level", "Starting at 7th level", "When you reach 10th level", "Prerequisite: 15th level", "By 11th level", "Beginning at..."
    final levelMatch = RegExp(r'(?:at|starting at|beginning at|reach|prerequisite:|by)\s+(\d+)(?:st|nd|rd|th)?\s+level').firstMatch(lower);
    if (levelMatch != null) {
      final featLevel = int.tryParse(levelMatch.group(1) ?? "0");
      if (featLevel != null && featLevel > currentLevel) return false;
    }
    return true;
  }

  Widget _featCard(String title, String content, IconData icon, Color color) {
    // Basic cleanup for the sheet view
    String cleanContent = content.replaceAll(RegExp(r'###|####|\*\*|_'), '').trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(cleanContent, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(Character char) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    // Passive calculations
    final int pPerception = 10 + (char.skills["Perception"] ?? 0);
    final int pInvestigation = 10 + (char.skills["Investigation"] ?? 0);
    final int pInsight = 10 + (char.skills["Insight"] ?? 0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 8 * scale,
            crossAxisSpacing: 8 * scale,
            childAspectRatio: 1.6,
            children: [
              _statBox("STR", char.strength, char.getModifier(char.strength)),
              _statBox("DEX", char.dexterity, char.getModifier(char.dexterity)),
              _statBox("CON", char.constitution, char.getModifier(char.constitution)),
              _statBox("INT", char.intelligence, char.getModifier(char.intelligence)),
              _statBox("WIS", char.wisdom, char.getModifier(char.wisdom)),
              _statBox("CHA", char.charisma, char.getModifier(char.charisma)),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Proficiency and Hit Dice Summary
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCombatStat("PROF", "+${char.proficiencyBonus}", Icons.military_tech),
                _buildCombatStat("HIT DICE", char.hitDice, Icons.casino),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),

          // Passive Values Section
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPassiveStat("PASSIVE PERC", "$pPerception", Icons.visibility),
                _buildPassiveStat("PASSIVE INV", "$pInvestigation", Icons.search),
                _buildPassiveStat("PASSIVE INS", "$pInsight", Icons.psychology),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassiveStat(String label, String value, IconData icon) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16 * scale),
            SizedBox(width: 4 * scale),
            Text(value, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        SizedBox(height: 2 * scale),
        Text(label, style: TextStyle(fontSize: 9 * scale, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSkillsTab(Character char) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);
    final bool isUnconscious = char.hpCurrent == 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SKILL CHECKS",
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          SizedBox(height: 12 * scale),
          _buildSkillsList(char, enabled: !isUnconscious),
        ],
      ),
    );
  }

  Widget _buildCombatGrid(Character char) {
    String speedValue;
    switch (_speedUnitIndex) {
      case 1: // Meters (standard D&D: 1.5m per 5ft)
        speedValue = "${(char.speed / 5 * 1.5).toStringAsFixed(1).replaceAll('.0', '')}m";
        break;
      case 2: // Squares (1 square per 5ft)
        speedValue = "${(char.speed / 5).floor()} sq";
        break;
      default: // Feet
        speedValue = "${char.speed}ft";
    }

    List<Widget> items = [
      _buildCombatStat("INIT", (char.initiative >= 0 ? "+${char.initiative}" : "${char.initiative}"), Icons.timer),
      GestureDetector(
        onTap: () {
          setState(() {
            _speedUnitIndex = (_speedUnitIndex + 1) % 3;
          });
        },
        child: _buildCombatStat("SPEED", speedValue, Icons.directions_run),
      ),
      _buildCombatStat("MELEE", "+${char.meleeHit}", Icons.colorize),
      _buildCombatStat("RANGED", "+${char.rangedHit}", Icons.gps_fixed),
    ];

    if (char.isSpellcaster) {
      items.add(_buildCombatStat("MAGIC", "+${char.spellAttackBonus}", Icons.auto_fix_high));
      items.add(_buildCombatStat("DC", "${char.spellSaveDc}", Icons.gavel));
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 0,
        childAspectRatio: 1.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  Widget _buildSkillsList(Character char, {bool enabled = true}) {
    final Map<String, int> skills = char.skills;
    final sortedSkills = skills.keys.toList()..sort();
    return Column(
      children: List.generate((sortedSkills.length / 2).ceil(), (index) {
        final leftSkill = sortedSkills[index * 2];
        final rightSkill = (index * 2 + 1 < sortedSkills.length) ? sortedSkills[index * 2 + 1] : null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Expanded(child: _skillRow(char, leftSkill, skills[leftSkill]!, enabled: enabled)),
              const SizedBox(width: 10),
              Expanded(child: rightSkill != null ? _skillRow(char, rightSkill, skills[rightSkill]!, enabled: enabled) : const SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _skillRow(Character char, String name, int mod, {bool enabled = true}) {
    final bool isProficient = char.proficiencies.contains(name);
    final bool isExpert = char.expertises.contains(name);

    BoxDecoration decoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white10),
    );

    if (isExpert) {
      decoration = BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent, width: 2),
      );
    } else if (isProficient) {
      decoration = BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent, width: 1),
      );
    }

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(name, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          ),
          Text(mod >= 0 ? "+$mod" : "$mod", 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        ],
      ),
    );

    // If it's expertise, we add an internal border by nesting
    if (isExpert) {
      content = Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
        ),
        child: content,
      );
    }

    return Container(
      decoration: decoration,
      child: InkWell(
        onTap: enabled ? () {
          final d20 = (DateTime.now().microsecondsSinceEpoch % 20) + 1;
          String res;
          if (d20 == 20) {
            res = "$name Check: NAT 20!";
          } else if (d20 == 1) {
            res = "$name Check: NAT 1!";
          } else {
            res = "$name Check: ${d20 + mod}";
          }
          
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res, 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        } : null,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.redAccent.withValues(alpha: 0.1),
        highlightColor: Colors.redAccent.withValues(alpha: 0.05),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: content,
        ),
      ),
    );
  }

  Widget _buildCombatStat(String label, String value, IconData icon) {
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
              Icon(icon, color: Colors.white70, size: 16 * scale),
              SizedBox(width: 4 * scale),
              Text(value, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        ),
        SizedBox(height: 2 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: TextStyle(fontSize: 10 * scale, color: Colors.grey, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _statBox(String label, int value, String mod) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: Colors.grey[900], 
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.white10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                //fixing main stats
                Text(label, style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold, color: Colors.white38)),
                SizedBox(width: 4 * scale),
                Text("$value", style: TextStyle(fontSize: 26 * scale, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(mod, style: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // --- INVENTORY AND SPELLS ---

  Widget? _buildFloatingActionButton(BuildContext context, Character char) {
    return ListenableBuilder(
      listenable: _tabController.animation!,
      builder: (context, child) {
        // Animation value is a double from 0 to totalTabs-1
        double value = _tabController.animation!.value;
        
        // Magic is index 4 (if available)
        bool showMagic = char.isSpellcaster && (value - 4).abs() < 0.5;

        if (showMagic) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddSpellMenu(context, char),
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.auto_fix_high, color: Colors.white),
            label: const Text("New Spell", style: TextStyle(color: Colors.white)),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSplitSpellsTab(BuildContext context, Character char) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (char.isSpellcaster) _buildMagicSlotsSummary(char),
        _buildSectionHeader("PREPARED SPELLS", Icons.flash_on),
        if (char.preparedSpells.isEmpty) _buildEmptyState("No spells ready"),
        ...char.preparedSpells.map((spell) => _buildItemTile(context, char, spell, false, true)),

        _buildSectionHeader("GRIMOIRE (KNOWN)", Icons.book),
        if (char.spells.isEmpty) _buildEmptyState("No spells known"),
        ...char.spells.map((spell) => _buildItemTile(context, char, spell, false, false)),
      ],
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
      child: Center(child: Text(text, style: TextStyle(color: Colors.white24, fontStyle: FontStyle.italic))),
    );
  }

  // --- TILE WITH CLICK VALIDATION ---
  Widget _buildItemTile(BuildContext context, Character char, dynamic item, bool isInventoryItem, bool isPrimaryList) {
    final String itemName = isInventoryItem ? (item as DndItem).name : (item as Spell).name;
    final String? itemSub = isInventoryItem ? null : (item as Spell).level;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = (screenWidth / 390).clamp(0.8, 1.2);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      color: isPrimaryList ? Colors.grey[800] : Colors.grey[900],
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale),
        leading: IconButton(
          icon: Icon(
            isInventoryItem
                ? (isPrimaryList ? Icons.check_circle : Icons.radio_button_unchecked)
                : (isPrimaryList ? Icons.star : Icons.star_border),
            color: isPrimaryList ? Colors.redAccent : Colors.grey,
            size: 24 * scale,
          ),
          onPressed: isInventoryItem
              ? () => _toggleEquipStatus(char, item as DndItem, isPrimaryList)
              : () => _toggleSpellPreparation(char, item as Spell, isPrimaryList),
        ),
        title: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: isPrimaryList ? FontWeight.bold : FontWeight.normal,
                    color: isPrimaryList ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
            if (itemSub != null)
              Padding(
                padding: EdgeInsets.only(left: 8.0 * scale),
                child: Text(
                  itemSub,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: isInventoryItem
            ? () => _showItemInfo(context, item as DndItem)
            : () => _showSpellDescription(context, char, item as Spell),
        onLongPress: () {
          if (isInventoryItem) {
            _showDeleteItemDialog(context, char, item as DndItem, isPrimaryList);
          } else {
            _showDeleteSpellDialog(context, char, item as Spell, isPrimaryList);
          }
        },
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

  void _toggleSpellPreparation(Character char, Spell spell, bool isCurrentlyPrepared) {
    setState(() {
      if (isCurrentlyPrepared) {
        char.preparedSpells.remove(spell);
        char.spells.add(spell);
      } else {
        char.spells.remove(spell);
        char.preparedSpells.add(spell);
      }
    });
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
  }

  void _showDeleteSpellDialog(BuildContext context, Character char, Spell spell, bool isPrepared) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Forget Spell?"),
        content: Text("Are you sure you want to remove '${spell.name}' from your grimoire?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isPrepared) {
                  char.preparedSpells.remove(spell);
                } else {
                  char.spells.remove(spell);
                }
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("REMOVE", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showSpellDescription(BuildContext context, Character char, Spell spell) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
        final isPrepared = char.preparedSpells.contains(spell);
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(spell.name)),
              IconButton(
                icon: Icon(isPrepared ? Icons.star : Icons.star_border, color: Colors.redAccent),
                onPressed: () {
                  _toggleSpellPreparation(char, spell, isPrepared);
                  setDialogState(() {});
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(spell.level == "0" ? "Cantrip" : "Level ${spell.level}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const SizedBox(height: 16),
                Text(spell.desc.isEmpty ? "No description available." : spell.desc),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
          ],
        );
      }),
    );
  }

  void _showAddSpellMenu(BuildContext context, Character char) async {
    if (!char.isSpellcaster) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${char.charClass}s cannot cast spells!"),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final Spell? selectedSpell = await showDialog<Spell>(
      context: context,
      builder: (ctx) => SpellSearch(
          characterLevel: char.level,
          className: char.charClass,
          customMode: char.customMode
      ),
    );

    if (selectedSpell != null) _addItem(char, selectedSpell, false);
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

  void _addItem(Character char, dynamic item, bool isInventory) {
    setState(() {
      if (isInventory) {
        char.inventory.add(item as DndItem);
      } else {
        char.spells.add(item as Spell);
      }
    });
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
  }

  Widget _buildDrawer(BuildContext context, Character char) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          _buildDrawerHeader(char),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerActionButton("BIO", () => _showBioDialog(char), icon: Icons.person),
                _drawerActionButton("INVENTORY", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => InventoryScreen(character: char)),
                  );
                }, icon: Icons.backpack),
                _drawerActionButton("LEVEL UP", () => _levelUp(char), icon: Icons.arrow_upward),
                _drawerActionButton("LONG REST", () => _longRest(char), icon: Icons.bed),
                _drawerActionButton("SHORT REST", () => _shortRest(char), icon: Icons.chair),
                _drawerActionButton("RENAME CHARACTER", () => _showRenameDialog(char), icon: Icons.edit),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.redAccent),
            title: const Text("MAIN MENU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(Character char) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(color: Colors.grey[900]),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageInsertDialog(char),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent, width: 2),
                image: char.imagePath != null && char.imagePath!.isNotEmpty
                    ? DecorationImage(
                        image: char.imagePath!.startsWith('http')
                            ? NetworkImage(char.imagePath!)
                            : FileImage(File(char.imagePath!)) as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: char.imagePath == null || char.imagePath!.isEmpty
                  ? const Icon(Icons.add_a_photo, color: Colors.white54, size: 40)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(char.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Level ${char.level} ${char.race} ${char.charClass}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _drawerActionButton(String title, VoidCallback onTap, {required IconData icon}) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showImageInsertDialog(Character char) {
    final TextEditingController ctrl = TextEditingController(text: char.imagePath);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Character Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    char.imagePath = image.path;
                  });
                  if (!mounted) return;
                  Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text("PICK FROM GALLERY"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 16),
            const Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                hintText: "Enter image URL",
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                char.imagePath = ctrl.text;
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text("SET URL"),
          )
        ],
      ),
    );
  }

  void _longRest(Character char) {
    setState(() {
      char.hpCurrent = char.hpMax;
      char.usedSpellSlots.clear();
      char.deathSavesSuccess = 0;
      char.deathSavesFailure = 0;
    });
    Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Long Rest: All HP and Spell Slots restored!")));
  }

  void _shortRest(Character char) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Short Rest"),
        content: const Text("Restore 25% of your max HP?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                char.hpCurrent = (char.hpCurrent + (char.hpMax ~/ 4)).clamp(0, char.hpMax);
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Short Rest complete!")));
            },
            child: const Text("RESTORE HP"),
          )
        ],
      ),
    );
  }

  void _showRenameDialog(Character char) {
    final TextEditingController ctrl = TextEditingController(text: char.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Character"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: "New Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                char.name = ctrl.text;
              });
              Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
              Navigator.pop(ctx);
            },
            child: const Text("RENAME"),
          )
        ],
      ),
    );
  }

  void _showBioDialog(Character char) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${char.name} Bio"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (char.subclass.isNotEmpty) _bioInfoItem("Subclass", char.subclass),
              _bioInfoItem("Physical Traits", char.physicalTraits),
              _bioInfoItem("Background", char.background),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  Widget _bioInfoItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 14)),
          const Divider(height: 8),
          Text(content.isEmpty ? "No information." : content, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  void _showDeathSavesDialog(Character char) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int? lastRoll;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isDead = char.deathSavesFailure >= 3;
            bool isStable = char.deathSavesSuccess >= 3;

            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(isDead ? "YOU ARE DEAD" : (isStable ? "STABILIZED" : "DEATH SAVING THROWS"), 
                textAlign: TextAlign.center,
                style: TextStyle(color: isDead ? Colors.red : (isStable ? Colors.green : Colors.white), fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isDead && !isStable) ...[
                    if (lastRoll != null)
                      Text("Rolled: $lastRoll", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("Roll to determine your fate.", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("SUCCESSES", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(3, (index) => Icon(
                                index < char.deathSavesSuccess ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: Colors.green,
                                size: 28,
                              )),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("FAILURES", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(3, (index) => Icon(
                                index < char.deathSavesFailure ? Icons.cancel : Icons.radio_button_unchecked,
                                color: Colors.red,
                                size: 28,
                              )),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        final d20 = Random().nextInt(20) + 1;
                        setDialogState(() {
                          lastRoll = d20;
                          if (d20 == 20) {
                            char.hpCurrent = 1;
                            char.deathSavesSuccess = 0;
                            char.deathSavesFailure = 0;
                            Navigator.pop(ctx);
                            _showToast("NAT 20! You regain 1 HP!");
                          } else if (d20 == 1) {
                            char.deathSavesFailure += 2;
                          } else if (d20 >= 10) {
                            char.deathSavesSuccess++;
                          } else {
                            char.deathSavesFailure++;
                          }
                        });
                        Provider.of<CharacterProvider>(context, listen: false).updateCharacter(char);
                        
                        if (char.deathSavesFailure >= 3) {
                           _showToast("You have succumbed to your wounds.");
                        } else if (char.deathSavesSuccess >= 3) {
                           _showToast("You are stable.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(120, 50),
                      ),
                      child: const Text("ROLL DEATH SAVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ] else if (isDead) ...[
                    const Icon(Icons.dangerous, color: Colors.red, size: 80),
                    const SizedBox(height: 16),
                    const Text("Your journey ends here.", style: TextStyle(color: Colors.white70)),
                  ] else ...[
                    const Icon(Icons.favorite, color: Colors.green, size: 80),
                    const SizedBox(height: 16),
                    const Text("You are unconscious but stable.", style: TextStyle(color: Colors.white70)),
                  ],
                ],
              ),
              actions: [
                if (isDead || isStable)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text("CLOSE", style: TextStyle(color: Colors.white54)),
                  ),
                if (!isDead && !isStable)
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }
}
