class Character {
  // ... (i campi esistenti: name, race, class, stats...)
  String name;
  String charClass;
  String race;
  String background;
  String physicalTraits;
  int level;
  int strength;
  int dexterity;
  int constitution;
  int intelligence;
  int wisdom;
  int charisma;
  int hpMax;

  // --- NUOVI CAMPI ---
  List<String> inventory;
  List<String> spells;

  Character({
    // ... (argomenti esistenti)
    this.name = '',
    this.charClass = 'Guerriero',
    this.race = 'Umano',
    this.background = '',
    this.physicalTraits = '',
    this.level = 1,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hpMax = 10,
    // Inizializziamo le liste vuote se non passate
    List<String>? inventory,
    List<String>? spells,
  }) : inventory = inventory ?? [], spells = spells ?? [];

  Map<String, dynamic> toJson() {
    return {
      // ... (tutti gli altri campi)
      'name': name,
      'charClass': charClass,
      'race': race,
      'background': background,
      'physicalTraits': physicalTraits,
      'level': level,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'hpMax': hpMax,
      // --- SALVATAGGIO LISTE ---
      'inventory': inventory,
      'spells': spells,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? '',
      charClass: json['charClass'] ?? 'Guerriero',
      // ... (altri campi) ...
      race: json['race'] ?? 'Umano',
      background: json['background'] ?? '',
      physicalTraits: json['physicalTraits'] ?? '',
      level: json['level'] ?? 1,
      strength: json['strength'] ?? 10,
      dexterity: json['dexterity'] ?? 10,
      constitution: json['constitution'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      wisdom: json['wisdom'] ?? 10,
      charisma: json['charisma'] ?? 10,
      hpMax: json['hpMax'] ?? 10,
      // --- CARICAMENTO LISTE ---
      // Dobbiamo convertire la lista dynamic in lista String
      inventory: List<String>.from(json['inventory'] ?? []),
      spells: List<String>.from(json['spells'] ?? []),
    );
  }

  String getModifier(int score) {
    int mod = (score - 10) ~/ 2;
    return mod >= 0 ? '+$mod' : '$mod';
  }
}