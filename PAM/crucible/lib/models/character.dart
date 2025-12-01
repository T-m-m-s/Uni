class Character {
  String name;
  String charClass;
  String race; // Nuovo
  int level;
  int strength;
  int dexterity;
  int constitution; // Nuovo
  int intelligence; // Nuovo
  int wisdom;       // Nuovo
  int charisma;     // Nuovo
  int hpMax;        // Nuovo

  Character({
    this.name = '',
    this.charClass = 'Fighter',
    this.race = 'Human',
    this.level = 1,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.hpMax = 10,
  });

  String getModifier(int score) {
    int mod = (score - 10) ~/ 2;
    return mod >= 0 ? '+$mod' : '$mod';
  }
}