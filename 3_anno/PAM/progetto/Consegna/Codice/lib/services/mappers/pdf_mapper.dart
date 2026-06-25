import '../../models/character.dart';

class PdfMapper {
  static Map<String, String> mapCharacterToPdf(Character char) {
    String modStr(int score) => char.getModifier(score);
    String strMod = modStr(char.strength);
    String dexMod = modStr(char.dexterity);
    String conMod = modStr(char.constitution);
    String intMod = modStr(char.intelligence);
    String wisMod = modStr(char.wisdom);
    String chaMod = modStr(char.charisma);

    List<int> slots = char.getSpellSlots();

    return <String, String>{
      // --- BASIC INFO ---
      'CharacterName': char.name,
      'PlayerName': 'Player',
      'ClassLevel': '${char.charClass} ${char.level}',
      'Background': char.background,
      'Race': char.race,
      'Alignment': 'N',
      'XP': '',

      // --- ABILITIES & STATS ---
      'STR': char.strength.toString(),
      'DEX': char.dexterity.toString(),
      'CON': char.constitution.toString(),
      'INT': char.intelligence.toString(),
      'WIS': char.wisdom.toString(),
      'CHA': char.charisma.toString(),

      'STRmod': strMod,
      'DEXmod': dexMod,
      'CONmod': conMod,
      'INTmod': intMod,
      'WISmod': wisMod,
      'CHAmod': chaMod,

      // --- COMBAT & STATS ---
      'AC': char.armorClass.toString(),
      'Initiative': dexMod,
      'Speed': '9m',
      'HPMax': char.hpMax.toString(),
      'HPCurrent': char.hpMax.toString(),
      'HPTemp': '',
      'HDTotal': char.level.toString(),
      'HD': 'd10',
      'ProfBonus': '+${((char.level - 1) ~/ 4) + 2}',
      'Passive': (10 + char.getModifierValue(char.wisdom)).toString(),

      // --- SAVING THROWS ---
      'ST Strength': strMod,
      'ST Dexterity': dexMod,
      'ST Constitution': conMod,
      'ST Intelligence': intMod,
      'ST Wisdom': wisMod,
      'ST Charisma': chaMod,

      // --- SKILLS ---
      'ACRO': dexMod,
      'ANIM': wisMod,
      'ARC': intMod,
      'ATH': strMod,
      'DEC': chaMod,
      'HIS': intMod,
      'INS': wisMod,
      'INTI': chaMod,
      'INV': intMod,
      'MED': wisMod,
      'NAT': intMod,
      'PERC': wisMod,
      'PERF': chaMod,
      'PERS': chaMod,
      'REL': intMod,
      'SLE': dexMod,
      'STLTH': dexMod,
      'SURV': wisMod,

      // --- EQUIPMENT ---
      'Wpn Name': char.equipped.isNotEmpty ? char.equipped[0].name.toString() : '',
      'Tratti car': char.physicalTraits,

      // --- SPELLS (Slots) ---
      'SlotsTotal 19': _getSlotValue(slots, 0),
      'SlotsTotal 20': _getSlotValue(slots, 1),
      'SlotsTotal 21': _getSlotValue(slots, 2),
      'SlotsTotal 22': _getSlotValue(slots, 3),
      'SlotsTotal 23': _getSlotValue(slots, 4),
      'SlotsTotal 24': _getSlotValue(slots, 5),
      'SlotsTotal 25': _getSlotValue(slots, 6),
      'SlotsTotal 26': _getSlotValue(slots, 7),
      'SlotsTotal 27': _getSlotValue(slots, 8),

      'SlotsRemaining 19': _getSlotValue(slots, 0),
      'SlotsRemaining 20': _getSlotValue(slots, 1),
      'SlotsRemaining 21': _getSlotValue(slots, 2),
      'SlotsRemaining 22': _getSlotValue(slots, 3),
      'SlotsRemaining 23': _getSlotValue(slots, 4),
      'SlotsRemaining 24': _getSlotValue(slots, 5),
      'SlotsRemaining 25': _getSlotValue(slots, 6),
      'SlotsRemaining 26': _getSlotValue(slots, 7),
      'SlotsRemaining 27': _getSlotValue(slots, 8),
    };
  }

  static String _getSlotValue(List<int> slots, int index) {
    return slots.length > index ? slots[index].toString() : '0';
  }
}
