class Character {
  String name;
  String charClass;
  int level;
  int strength;
  int dexterity;
  // Aggiungi qui gli altri campi (Constitution, HP, ecc.)

  Character({
    this.name = '',
    this.charClass = 'Fighter',
    this.level = 1,
    this.strength = 10,
    this.dexterity = 10,
  });

  // Metodo utile per calcolare il modificatore (es. 16 diventa +3)
  String getModifier(int score) {
    int mod = (score - 10) ~/ 2;
    return mod >= 0 ? '+$mod' : '$mod';
  }
}