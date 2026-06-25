import '../core/utils/rules_engine.dart';
import 'package:crucible/models/dnd_item.dart';
export 'package:crucible/models/dnd_item.dart';

class Character {
  String name;
  String charClass;
  String subclass;
  String subclassFeat;
  String race;
  String background;
  String physicalTraits;
  List<Note> notes;
  String originFeat;
  String raceFeat;
  String classFeat;
  bool customMode;
  String? imagePath;
  int level;
  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;
  int hpMax;
  int hpCurrent;
  Map<int, int> usedSpellSlots;
  int deathSavesSuccess;
  int deathSavesFailure;
  List<String> proficiencies;
  List<String> expertises;

  // --- LISTS ---
  List<DndItem> inventory;      // Backpack
  List<DndItem> equipped;       // Current Equipment
  List<Spell> spells;           // Grimoire (All known spells)
  List<Spell> preparedSpells;   // Current Spells (Memorized)

  Character({
    this.name = '',
    this.charClass = 'Fighter',
    this.subclass = '',
    this.subclassFeat = '',
    this.race = 'Human',
    this.background = '',
    this.physicalTraits = '',
    List<Note>? notes,
    this.originFeat = '',
    this.raceFeat = '',
    this.classFeat = '',
    this.customMode = false,
    this.imagePath,
    this.level = 1,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hpMax = 10,
    int? hpCurrent,
    Map<int, int>? usedSpellSlots,
    this.deathSavesSuccess = 0,
    this.deathSavesFailure = 0,
    List<String>? proficiencies,
    List<String>? expertises,
    List<DndItem>? inventory,
    List<DndItem>? equipped,
    List<Spell>? spells,
    List<Spell>? preparedSpells,
  }) :
        inventory = inventory ?? [],
        equipped = equipped ?? [],
        spells = spells ?? [],
        preparedSpells = preparedSpells ?? [],
        usedSpellSlots = usedSpellSlots ?? {},
        hpCurrent = hpCurrent ?? hpMax,
        notes = notes ?? [],
        proficiencies = proficiencies ?? [],
        expertises = expertises ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'charClass': charClass,
      'subclass': subclass,
      'subclassFeat': subclassFeat,
      'race': race,
      'background': background,
      'physicalTraits': physicalTraits,
      'notes': notes.map((e) => e.toJson()).toList(),
      'originFeat': originFeat,
      'raceFeat': raceFeat,
      'classFeat': classFeat,
      'customMode': customMode,
      'imagePath': imagePath,
      'level': level,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'hpMax': hpMax,
      'hpCurrent': hpCurrent,
      'deathSavesSuccess': deathSavesSuccess,
      'deathSavesFailure': deathSavesFailure,
      'usedSpellSlots': usedSpellSlots.map((k, v) => MapEntry(k.toString(), v)),
      'proficiencies': proficiencies,
      'expertises': expertises,
      // Liste
      'inventory': inventory.map((e) => e.toJson()).toList(),
      'equipped': equipped.map((e) => e.toJson()).toList(),
      'spells': spells.map((e) => e.toJson()).toList(),
      'preparedSpells': preparedSpells.map((e) => e.toJson()).toList(),
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    int maxHp = json['hpMax'] ?? 10;
    return Character(
      name: json['name'] ?? '',
      charClass: json['charClass'] ?? 'Fighter',
      subclass: json['subclass'] ?? '',
      subclassFeat: json['subclassFeat'] ?? '',
      race: json['race'] ?? 'Human',
      background: json['background'] ?? '',
      physicalTraits: json['physicalTraits'] ?? '',
      notes: (json['notes'] as List?)?.map((n) => Note.fromJson(n)).toList() ?? [],
      originFeat: json['originFeat'] ?? '',
      raceFeat: json['raceFeat'] ?? '',
      classFeat: json['classFeat'] ?? '',
      customMode: json['customMode'] ?? false,
      imagePath: json['imagePath'],
      level: json['level'] ?? 1,
      strength: json['strength'] ?? 10,
      dexterity: json['dexterity'] ?? 10,
      constitution: json['constitution'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      wisdom: json['wisdom'] ?? 10,
      charisma: json['charisma'] ?? 10,
      hpMax: maxHp,
      hpCurrent: json['hpCurrent'] ?? maxHp,
      deathSavesSuccess: json['deathSavesSuccess'] ?? 0,
      deathSavesFailure: json['deathSavesFailure'] ?? 0,
      usedSpellSlots: (json['usedSpellSlots'] as Map?)?.map((k, v) => MapEntry(int.parse(k), v as int)) ?? {},
      proficiencies: List<String>.from(json['proficiencies'] ?? []),
      expertises: List<String>.from(json['expertises'] ?? []),
      inventory: (json['inventory'] as List?)?.map((i) => DndItem.fromJson(i)).toList() ?? [],
      equipped: (json['equipped'] as List?)?.map((i) => DndItem.fromJson(i)).toList() ?? [],
      spells: (json['spells'] as List?)?.map((s) => Spell.fromJson(s)).toList() ?? [],
      preparedSpells: (json['preparedSpells'] as List?)?.map((s) => Spell.fromJson(s)).toList() ?? [],
    );
  }

  // Proxy methods to RulesEngine for convenience
  String getModifier(int score) => RulesEngine.getModifier(score);
  int getModifierValue(int score) => RulesEngine.getModifierValue(score);
  
  int get proficiencyBonus => RulesEngine.calculateProficiencyBonus(level);
  
  int get spellcastingModifier {
    String ability = RulesEngine.getSpellcastingAbility(charClass);
    if (ability == "NONE") return 0;
    
    int score = 10;
    switch (ability) {
      case "STRENGTH": score = strength; break;
      case "DEXTERITY": score = dexterity; break;
      case "CONSTITUTION": score = constitution; break;
      case "INTELLIGENCE": score = intelligence; break;
      case "WISDOM": score = wisdom; break;
      case "CHARISMA": score = charisma; break;
    }
    return getModifierValue(score);
  }

  int get spellAttackBonus => RulesEngine.calculateSpellAttackBonus(proficiencyBonus, spellcastingModifier);
  int get spellSaveDc => RulesEngine.calculateSpellSaveDC(proficiencyBonus, spellcastingModifier);
  
  int get meleeHit => RulesEngine.calculateMeleeHit(proficiencyBonus, getModifierValue(strength));
  int get rangedHit => RulesEngine.calculateRangedHit(proficiencyBonus, getModifierValue(dexterity));
  int get initiative => getModifierValue(dexterity);
  int get speed => RulesEngine.getBaseSpeed(race);
  
  Map<String, int> get skills {
    final skillAbilities = RulesEngine.getSkillAbilities();
    Map<String, int> results = {};
    
    skillAbilities.forEach((skill, ability) {
      int score = 10;
      switch (ability) {
        case "STRENGTH": score = strength; break;
        case "DEXTERITY": score = dexterity; break;
        case "CONSTITUTION": score = constitution; break;
        case "INTELLIGENCE": score = intelligence; break;
        case "WISDOM": score = wisdom; break;
        case "CHARISMA": score = charisma; break;
      }
      int baseMod = getModifierValue(score);
      if (expertises.contains(skill)) {
        results[skill] = baseMod + (proficiencyBonus * 2);
      } else if (proficiencies.contains(skill)) {
        results[skill] = baseMod + proficiencyBonus;
      } else {
        results[skill] = baseMod;
      }
    });
    return results;
  }

  String get hitDice => "${level}d${RulesEngine.isSpellcaster(charClass, customMode) ? (charClass.toLowerCase().contains('wizard') || charClass.toLowerCase().contains('sorcerer') ? 6 : 8) : (charClass.toLowerCase().contains('barbarian') ? 12 : 10)}";

  int get armorClass => RulesEngine.calculateArmorClass(
    dexterity: dexterity,
    constitution: constitution,
    wisdom: wisdom,
    charClass: charClass,
    equipped: equipped.map<String>((e) => e.name).toList()
  );
  List<int> getSpellSlots() => RulesEngine.getSpellSlots(charClass, level);
  bool get isSpellcaster => RulesEngine.isSpellcaster(charClass, customMode);
}

enum NoteCategory { characters, locations, quests, general }

class Note {
  String title;
  String content;
  NoteCategory category;

  Note({
    this.title = '',
    this.content = '',
    this.category = NoteCategory.general,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category.name,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: NoteCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NoteCategory.general,
      ),
    );
  }
}

class Spell {
  String name;
  String level;
  String desc;

  Spell({required this.name, required this.level, this.desc = ''});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'desc': desc,
    };
  }

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      desc: json['desc'] ?? '',
    );
  }
}
