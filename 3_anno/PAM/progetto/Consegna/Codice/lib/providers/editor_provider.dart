import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/character.dart';
import '../core/utils/rules_engine.dart';
import '../services/dnd_api_services.dart';

class EditorProvider with ChangeNotifier {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController raceCtrl = TextEditingController(text: "Human");
  final TextEditingController classCtrl = TextEditingController(text: "Fighter");
  final TextEditingController subclassCtrl = TextEditingController();
  final TextEditingController backgroundCtrl = TextEditingController();
  final TextEditingController physicalCtrl = TextEditingController();
  final TextEditingController traitsCtrl = TextEditingController();

  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  EditorProvider() {
    traitsCtrl.addListener(() {
      notifyListeners();
    });
  }

  Future<void> initDefaults() async {
    final api = DndApiService();
    
    try {
      // Carichiamo dati per "Human" e "Fighter"
      final races = await api.getAllRaces();
      final classes = await api.getAllClasses();

      final defaultRace = races.firstWhere(
        (r) => r['name'].toString().toLowerCase() == raceCtrl.text.toLowerCase(),
        orElse: () => null,
      );
      
      final defaultClass = classes.firstWhere(
        (c) => c['name'].toString().toLowerCase() == classCtrl.text.toLowerCase(),
        orElse: () => null,
      );

      if (defaultRace != null) selectRace(defaultRace);
      if (defaultClass != null) selectClass(defaultClass);
    } catch (e) {
      debugPrint("Errore init defaults: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  int str = 10;
  int dex = 10;
  int con = 10;
  int intel = 10;
  int wis = 10;
  int cha = 10;
  bool customMode = false;
  int level = 1;

  // Stat Generation Modes
  String statMethod = "Standard"; // Manual, Standard, PointBuy, Dice
  int pointBuyPool = 27;
  List<int> diceResults = [];
  final List<int> standardArray = [15, 14, 13, 12, 10, 8];
  Map<String, int?> assignedIndices = {}; // Mappa stat -> indice nel pool (standardArray o diceResults)

  // Background 2024 Logic
  List<String> allowedBackgroundStats = []; // e.g., ["INTELLIGENCE", "WISDOM", "CHARISMA"]
  Map<String, int> selectedBgBonuses = {};   // e.g., {"WISDOM": 2, "INTELLIGENCE": 1}
  String? backgroundFeat;
  String? raceFeat;
  String? classFeat;
  String? subclassFeat;
  Map<String, dynamic>? classData;

  int get totalStr => str + (selectedBgBonuses['STRENGTH'] ?? 0);
  int get totalDex => dex + (selectedBgBonuses['DEXTERITY'] ?? 0);
  int get totalCon => con + (selectedBgBonuses['CONSTITUTION'] ?? 0);
  int get totalInt => intel + (selectedBgBonuses['INTELLIGENCE'] ?? 0);
  int get totalWis => wis + (selectedBgBonuses['WISDOM'] ?? 0);
  int get totalCha => cha + (selectedBgBonuses['CHARISMA'] ?? 0);

  // --- COMBAT & MAGIC STATS ---
  int get proficiencyBonus => RulesEngine.calculateProficiencyBonus(level);
  
  int get spellcastingModifier {
    String ability = RulesEngine.getSpellcastingAbility(classCtrl.text);
    return RulesEngine.getModifierValue(getStatValue(ability));
  }

  int get spellAttackBonus => RulesEngine.calculateSpellAttackBonus(proficiencyBonus, spellcastingModifier);
  int get spellSaveDc => RulesEngine.calculateSpellSaveDC(proficiencyBonus, spellcastingModifier);
  
  int get meleeHit => RulesEngine.calculateMeleeHit(proficiencyBonus, RulesEngine.getModifierValue(totalStr));
  int get rangedHit => RulesEngine.calculateRangedHit(proficiencyBonus, RulesEngine.getModifierValue(totalDex));

  int get speed => RulesEngine.getBaseSpeed(raceCtrl.text);

  Map<String, int> get skills {
    final skillAbilities = RulesEngine.getSkillAbilities();
    Map<String, int> results = {};
    
    skillAbilities.forEach((skill, ability) {
      results[skill] = RulesEngine.getModifierValue(getStatValue(ability));
    });
    return results;
  }

  String get hitDice => "$level${classData?['hit_dice']?.toString().replaceFirst('1', '') ?? 'd8'}";

  int get initiative => RulesEngine.getModifierValue(totalDex);

  bool get isSpellcaster => RulesEngine.isSpellcaster(classCtrl.text, customMode);

  // --- DYNAMIC HP CALCULATION ---
  int get currentMaxHp {
    // Retrieve hit dice from class data (Open5e uses 'hit_dice')
    String hitDie = classData?['hit_dice'] ?? "1d8";
    
    // Check if the character has the Tough feat
    bool hasTough = (backgroundFeat?.toLowerCase().contains("tough") ?? false) || 
                   (traitsCtrl.text.toLowerCase().contains("tough"));

    bool isHillDwarf = raceCtrl.text.toLowerCase().contains("hill dwarf");

    return RulesEngine.calculateMaxHp(
      hitDieStr: hitDie, 
      level: level, 
      conScore: totalCon,
      hasToughFeat: hasTough,
      isHillDwarf: isHillDwarf,
    );
  }

  // --- DYNAMIC AC CALCULATION (PREVIEW) ---
  int get currentBaseAc {
    return RulesEngine.calculateArmorClass(
      dexterity: totalDex,
      constitution: totalCon,
      wisdom: totalWis,
      charClass: classCtrl.text,
      equipped: inventory.where((i) => i.name.contains("(AC")).map((e) => e.name).toList(), // Simulate equipment for preview
    );
  }

  final List<DndItem> inventory = [];
  final List<Spell> spells = [];
  final List<String> proficiencies = [];
  final List<String> expertises = [];

  void setStat(String stat, int value) {
    if (statMethod == "PointBuy") {
      int currentVal = getStatValue(stat);
      int newCost = _getPointBuyCost(value);
      int oldCost = _getPointBuyCost(currentVal);
      
      if (pointBuyPool + oldCost - newCost >= 0) {
        pointBuyPool = pointBuyPool + oldCost - newCost;
      } else {
        return; // Not enough points
      }
    }

    switch (stat) {
      case 'STRENGTH': str = value; break;
      case 'DEXTERITY': dex = value; break;
      case 'CONSTITUTION': con = value; break;
      case 'INTELLIGENCE': intel = value; break;
      case 'WISDOM': wis = value; break;
      case 'CHARISMA': cha = value; break;
    }
    notifyListeners();
  }

  int getStatValue(String stat) {
    switch (stat) {
      case 'STRENGTH': return str;
      case 'DEXTERITY': return dex;
      case 'CONSTITUTION': return con;
      case 'INTELLIGENCE': return intel;
      case 'WISDOM': return wis;
      case 'CHARISMA': return cha;
      default: return 10;
    }
  }

  void setStatMethod(String method) {
    statMethod = method;
    // Reset stats
    str = (method == "PointBuy") ? 8 : 10;
    dex = (method == "PointBuy") ? 8 : 10;
    con = (method == "PointBuy") ? 8 : 10;
    intel = (method == "PointBuy") ? 8 : 10;
    wis = (method == "PointBuy") ? 8 : 10;
    cha = (method == "PointBuy") ? 8 : 10;
    
    pointBuyPool = 27;
    assignedIndices.clear();
    if (method == "Dice") {
      rollStats();
    }
    notifyListeners();
  }

  int _getPointBuyCost(int score) {
    if (score <= 8) return 0;
    if (score == 9) return 1;
    if (score == 10) return 2;
    if (score == 11) return 3;
    if (score == 12) return 4;
    if (score == 13) return 5;
    if (score == 14) return 7;
    if (score == 15) return 9;
    return 9;
  }

  void rollStats() {
    final random = Random();
    diceResults = List.generate(6, (i) {
      List<int> rolls = List.generate(4, (j) => random.nextInt(6) + 1);
      rolls.sort();
      return rolls.skip(1).reduce((a, b) => a + b);
    });
    diceResults.sort((a, b) => b.compareTo(a));
  }

  void assignStat(String statName, int? index) {
    final List<int> pool = statMethod == "Standard" ? standardArray : diceResults;

    if (index == null) {
      assignedIndices.remove(statName);
      _updateRawStat(statName, 10);
    } else {
      // If the index was already assigned to another stat, remove it from there
      assignedIndices.removeWhere((key, val) => val == index);
      assignedIndices[statName] = index;
      _updateRawStat(statName, pool[index]);
    }
    notifyListeners();
  }

  void _updateRawStat(String statName, int value) {
    switch (statName) {
      case 'STRENGTH': str = value; break;
      case 'DEXTERITY': dex = value; break;
      case 'CONSTITUTION': con = value; break;
      case 'INTELLIGENCE': intel = value; break;
      case 'WISDOM': wis = value; break;
      case 'CHARISMA': cha = value; break;
    }
  }

  void setCustomMode(bool value) {
    customMode = value;
    notifyListeners();
  }

  void setLevel(int val) {
    level = val;
    _pruneSpells();
    notifyListeners();
  }

  void _pruneSpells() {
    if (customMode) return;
    
    int maxLvl = (level + 1) ~/ 2;
    spells.removeWhere((spell) {
      int spellLvl = _parseSpellLevel(spell.level);
      return spellLvl > maxLvl;
    });
  }

  int _parseSpellLevel(String levelStr) {
    String lower = levelStr.toLowerCase();
    if (lower.contains("cantrip")) return 0;
    final RegExp regExp = RegExp(r'\d+');
    final match = regExp.firstMatch(lower);
    return match != null ? int.parse(match.group(0)!) : 99;
  }

  void addToInventory(DndItem item) {
    inventory.add(item);
    notifyListeners();
  }

  void removeFromInventory(int index) {
    inventory.removeAt(index);
    notifyListeners();
  }

  void addToSpells(Spell spell) {
    spells.add(spell);
    notifyListeners();
  }

  void removeFromSpells(int index) {
    spells.removeAt(index);
    notifyListeners();
  }

  void toggleProficiency(String skill) {
    if (proficiencies.contains(skill)) {
      proficiencies.remove(skill);
      expertises.remove(skill); // Expertise requires proficiency
    } else {
      proficiencies.add(skill);
    }
    notifyListeners();
  }

  void toggleExpertise(String skill) {
    if (expertises.contains(skill)) {
      expertises.remove(skill);
    } else {
      expertises.add(skill);
      if (!proficiencies.contains(skill)) {
        proficiencies.add(skill);
      }
    }
    notifyListeners();
  }

  void clearSpells() {
    spells.clear();
    notifyListeners();
  }

  void updateRace(String race) {
    raceCtrl.text = race;
    notifyListeners();
  }

  void updateClass(String className) {
    if (classCtrl.text != className) {
      classCtrl.text = className;
      clearSpells();
    }
    notifyListeners();
  }

  void selectRace(Map<String, dynamic> raceData) {
    raceCtrl.text = raceData['name'];
    // Extract traits/features
    raceFeat = raceData['traits'] ?? raceData['desc'] ?? "";
    notifyListeners();
  }

  void selectClass(Map<String, dynamic> data) {
    if (classCtrl.text != data['name']) {
      classCtrl.text = data['name'];
      subclassCtrl.clear();
      clearSpells();
    }
    classData = data;
    classFeat = data['prof_desc'] ?? data['desc'] ?? "";
    notifyListeners();
  }

  void selectSubclass(Map<String, dynamic> data) {
    subclassCtrl.text = data['name'];
    subclassFeat = data['desc'] ?? "";
    notifyListeners();
  }

  void selectBackground(Map<String, dynamic> bgData) {
    backgroundCtrl.text = bgData['name'];
    
    // Open5e 'stats' field typically looks like "Intelligence, Wisdom, or Charisma"
    allowedBackgroundStats = _parseStats(bgData['stats'] ?? ""); 
    
    // Reset previous choices
    selectedBgBonuses.clear();
    
    // The feat might be in a 'feat' field or we might need to look for it in 'desc'
    backgroundFeat = bgData['feat'] ?? _extractFeatFromDesc(bgData['desc'] ?? "");
    
    notifyListeners();
  }

  void applyManualBonus(String stat, int value) {
    // Logic to ensure they don't exceed the +2/+1 or +1/+1/+1 limit
    // For simplicity here, we just set it. UI should handle the choices.
    selectedBgBonuses[stat] = value;
    notifyListeners();
  }

  List<String> _parseStats(String statsStr) {
    List<String> result = [];
    final lower = statsStr.toLowerCase();
    if (lower.contains("strength")) result.add("STRENGTH");
    if (lower.contains("dexterity")) result.add("DEXTERITY");
    if (lower.contains("constitution")) result.add("CONSTITUTION");
    if (lower.contains("intelligence")) result.add("INTELLIGENCE");
    if (lower.contains("wisdom")) result.add("WISDOM");
    if (lower.contains("charisma")) result.add("CHARISMA");
    return result;
  }

  String? _extractFeatFromDesc(String desc) {
    // Basic heuristic: look for "Feat:" or similar in description
    if (desc.contains("Origin Feat:")) {
      final List<String> parts = desc.split("Origin Feat:");
      if (parts.length > 1) {
        return parts[1].split("\n")[0].trim();
      }
    }
    return null;
  }

  Character createCharacter() {
    return Character(
      name: nameCtrl.text,
      charClass: classCtrl.text,
      subclass: subclassCtrl.text,
      race: raceCtrl.text,
      background: backgroundCtrl.text,
      physicalTraits: nameCtrl.text.isEmpty ? '' : physicalCtrl.text,
      notes: traitsCtrl.text.isEmpty ? [] : [Note(title: 'Initial Notes', content: traitsCtrl.text)],
      originFeat: backgroundFeat ?? '',
      raceFeat: raceFeat ?? '',
      classFeat: classFeat ?? '',
      subclassFeat: subclassFeat ?? '',
      customMode: customMode,
      level: level,
      strength: totalStr,
      dexterity: totalDex,
      constitution: totalCon,
      intelligence: totalInt,
      wisdom: totalWis,
      charisma: totalCha,
      hpMax: currentMaxHp,
      inventory: List.from(inventory),
      spells: List.from(spells),
      proficiencies: List.from(proficiencies),
      expertises: List.from(expertises),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    raceCtrl.dispose();
    classCtrl.dispose();
    subclassCtrl.dispose();
    backgroundCtrl.dispose();
    physicalCtrl.dispose();
    traitsCtrl.dispose();
    super.dispose();
  }
}
