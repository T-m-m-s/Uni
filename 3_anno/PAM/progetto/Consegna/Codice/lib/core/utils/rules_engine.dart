class RulesEngine {
  static int getModifierValue(int score) {
    return (score - 10) ~/ 2;
  }

  static String getModifier(int score) {
    int mod = getModifierValue(score);
    return mod >= 0 ? '+$mod' : '$mod';
  }

  static int calculateProficiencyBonus(int level) {
    return (level - 1) ~/ 4 + 2;
  }

  static String getSpellcastingAbility(String charClass) {
    String cls = charClass.toLowerCase();
    if (['wizard'].contains(cls)) return "INTELLIGENCE";
    if (['cleric', 'druid', 'ranger'].contains(cls)) return "WISDOM";
    if (['bard', 'sorcerer', 'warlock', 'paladin'].contains(cls)) return "CHARISMA";
    return "NONE";
  }

  static int calculateSpellAttackBonus(int proficiency, int modifier) {
    return proficiency + modifier;
  }

  static int calculateSpellSaveDC(int proficiency, int modifier) {
    return 8 + proficiency + modifier;
  }

  static int calculateMeleeHit(int proficiency, int strModifier) {
    return proficiency + strModifier;
  }

  static int calculateRangedHit(int proficiency, int dexModifier) {
    return proficiency + dexModifier;
  }

  static int getBaseSpeed(String race) {
    String r = race.toLowerCase();
    if (r.contains("dwarf") || r.contains("halfling") || r.contains("gnome")) {
      return 25;
    }
    return 30;
  }

  static Map<String, String> getSkillAbilities() {
    return {
      "Acrobatics": "DEXTERITY",
      "Animal Handling": "WISDOM",
      "Arcana": "INTELLIGENCE",
      "Athletics": "STRENGTH",
      "Deception": "CHARISMA",
      "History": "INTELLIGENCE",
      "Insight": "WISDOM",
      "Intimidation": "CHARISMA",
      "Investigation": "INTELLIGENCE",
      "Medicine": "WISDOM",
      "Nature": "INTELLIGENCE",
      "Perception": "WISDOM",
      "Performance": "CHARISMA",
      "Persuasion": "CHARISMA",
      "Religion": "INTELLIGENCE",
      "Sleight of Hand": "DEXTERITY",
      "Stealth": "DEXTERITY",
      "Survival": "WISDOM",
    };
  }

  static List<String> getClassSkills(String charClass) {
    String cls = charClass.toLowerCase();
    if (cls.contains("barbarian")) return ["Animal Handling", "Athletics", "Intimidation", "Nature", "Perception", "Survival"];
    if (cls.contains("bard")) return getSkillAbilities().keys.toList(); // Bards can choose any
    if (cls.contains("cleric")) return ["History", "Insight", "Medicine", "Persuasion", "Religion"];
    if (cls.contains("druid")) return ["Arcana", "Animal Handling", "Insight", "Medicine", "Nature", "Perception", "Religion", "Survival"];
    if (cls.contains("fighter")) return ["Acrobatics", "Animal Handling", "Athletics", "History", "Insight", "Intimidation", "Perception", "Survival"];
    if (cls.contains("monk")) return ["Acrobatics", "Athletics", "History", "Insight", "Religion", "Stealth"];
    if (cls.contains("paladin")) return ["Athletics", "Insight", "Intimidation", "Medicine", "Persuasion", "Religion"];
    if (cls.contains("ranger")) return ["Animal Handling", "Athletics", "Insight", "Investigation", "Nature", "Perception", "Stealth", "Survival"];
    if (cls.contains("rogue")) return ["Acrobatics", "Athletics", "Deception", "Insight", "Intimidation", "Investigation", "Perception", "Performance", "Persuasion", "Sleight of Hand", "Stealth"];
    if (cls.contains("sorcerer")) return ["Arcana", "Deception", "Insight", "Intimidation", "Persuasion", "Religion"];
    if (cls.contains("warlock")) return ["Arcana", "Deception", "History", "Intimidation", "Investigation", "Nature", "Religion"];
    if (cls.contains("wizard")) return ["Arcana", "History", "Insight", "Investigation", "Medicine", "Religion"];
    return getSkillAbilities().keys.toList(); // Default to all if unknown
  }

  static int getClassSkillCount(String charClass) {
    String cls = charClass.toLowerCase();
    if (cls.contains("rogue")) return 4;
    if (cls.contains("bard") || cls.contains("ranger")) return 3;
    return 2; // Most other classes get 2
  }

  static bool canHaveExpertise(String charClass, int level) {
    String cls = charClass.toLowerCase();
    if (cls.contains("rogue")) return true; 
    if (cls.contains("bard") && level >= 3) return true; 
    if (cls.contains("ranger")) return true; 
    return false;
  }

  static int getClassExpertiseCount(String charClass, int level) {
    String cls = charClass.toLowerCase();
    if (cls.contains("rogue")) {
      return level >= 6 ? 4 : 2;
    }
    if (cls.contains("bard")) {
      if (level < 3) return 0;
      return level >= 10 ? 4 : 2;
    }
    if (cls.contains("ranger")) return 1;
    return 0;
  }

  static int calculateMaxHp({
    required String hitDieStr,
    required int level,
    required int conScore,
    bool hasToughFeat = false,
    bool isHillDwarf = false,
  }) {
    // 1. Extract the die value (e.g., "1d10" -> 10)
    final int dieValue = int.tryParse(hitDieStr.toLowerCase().replaceAll('1d', '')) ?? 8;
    int conMod = getModifierValue(conScore);

    // 2. Base calculation: Level 1 (Max Die) + Subsequent levels (Average: half die + 1)
    // HP = (Die) + (Con) + (Level-1)*(Die/2 + 1 + Con)
    int firstLevelHp = dieValue + conMod;
    int subsequentLevelsHp = (level - 1) * ((dieValue ~/ 2) + 1 + conMod);

    int totalHp = firstLevelHp + subsequentLevelsHp;

    // 3. "Tough" Feat: +2 HP per level
    if (hasToughFeat) {
      totalHp += (2 * level);
    }

    // 4. Hill Dwarf: +1 HP per level
    if (isHillDwarf) {
      totalHp += level;
    }

    // Minimum 1 HP per level
    return totalHp > level ? totalHp : level;
  }

  static int calculateArmorClass({
    required int dexterity,
    required int constitution,
    required int wisdom,
    required String charClass,
    required List<String> equipped,
  }) {
    int dexMod = getModifierValue(dexterity);
    int conMod = getModifierValue(constitution);
    int wisMod = getModifierValue(wisdom);
    
    bool hasArmor = equipped.any((i) {
      String lowerI = i.toLowerCase();
      return lowerI.contains("(ac") && !lowerI.contains("shield");
    });
    bool hasShield = equipped.any((i) {
      String lowerI = i.toLowerCase();
      return lowerI.contains("shield");
    });

    // --- UNARMORED DEFENSE ---
    if (!hasArmor) {
      String cls = charClass.toLowerCase();
      if (cls.contains("monk")) {
        // Monk: 10 + DEX + WIS (Only if without shield)
        return hasShield ? (10 + dexMod) : (10 + dexMod + wisMod);
      }
      if (cls.contains("barbarian")) {
        // Barbarian: 10 + DEX + CON (Works with shield)
        return 10 + dexMod + conMod + (hasShield ? 2 : 0);
      }
      // Standard: 10 + DEX
      return 10 + dexMod + (hasShield ? 2 : 0);
    }

    // --- TRADITIONAL ARMOR LOGIC ---
    int baseAc = 10;
    int shieldBonus = hasShield ? 2 : 0;
    int magicBonus = 0;
    
    for (String item in equipped) {
      String lowerItem = item.toLowerCase();
      if (lowerItem.contains("shield")) continue; // Already calculated

      final RegExp acRegex = RegExp(r"ac\s*(\d+)");
      final match = acRegex.firstMatch(lowerItem);

      if (match != null) {
        int itemAc = int.parse(match.group(1)!);

        if (lowerItem.contains("heavy")) {
          baseAc = itemAc;
        } else if (lowerItem.contains("medium")) {
          baseAc = itemAc + (dexMod > 2 ? 2 : dexMod);
        } else {
          baseAc = itemAc + dexMod;
        }
      }
      if (lowerItem.contains("+1")) magicBonus += 1;
      if (lowerItem.contains("+2")) magicBonus += 2;
      if (lowerItem.contains("+3")) magicBonus += 3;
    }

    return baseAc + shieldBonus + magicBonus;
  }

  static List<int> getSpellSlots(String charClass, int level) {
    if (level < 1) return List.filled(9, 0);

    String cls = charClass.toLowerCase();

    if (['wizard', 'sorcerer', 'bard', 'cleric', 'druid'].contains(cls)) {
      return _getStandardSlots(level);
    }

    if (['paladin', 'ranger'].contains(cls)) {
      int effectiveLevel = (level / 2).floor();
      return _getStandardSlots(effectiveLevel);
    }

    if (['warlock'].contains(cls)) {
      return _getWarlockSlots(level);
    }

    return List.filled(9, 0);
  }

  static List<int> _getStandardSlots(int casterLevel) {
    if (casterLevel <= 0) return List.filled(9, 0);

    switch (casterLevel) {
      case 1:  return [2, 0, 0, 0, 0, 0, 0, 0, 0];
      case 2:  return [3, 0, 0, 0, 0, 0, 0, 0, 0];
      case 3:  return [4, 2, 0, 0, 0, 0, 0, 0, 0];
      case 4:  return [4, 3, 0, 0, 0, 0, 0, 0, 0];
      case 5:  return [4, 3, 2, 0, 0, 0, 0, 0, 0];
      case 6:  return [4, 3, 3, 0, 0, 0, 0, 0, 0];
      case 7:  return [4, 3, 3, 1, 0, 0, 0, 0, 0];
      case 8:  return [4, 3, 3, 2, 0, 0, 0, 0, 0];
      case 9:  return [4, 3, 3, 3, 1, 0, 0, 0, 0];
      case 10: return [4, 3, 3, 3, 2, 0, 0, 0, 0];
      case 11:
      case 12: return [4, 3, 3, 3, 2, 1, 0, 0, 0];
      case 13:
      case 14: return [4, 3, 3, 3, 2, 1, 1, 0, 0];
      case 15:
      case 16: return [4, 3, 3, 3, 2, 1, 1, 1, 0];
      case 17: return [4, 3, 3, 3, 2, 1, 1, 1, 1];
      case 18: return [4, 3, 3, 3, 3, 1, 1, 1, 1];
      case 19: return [4, 3, 3, 3, 3, 2, 1, 1, 1];
      case 20: return [4, 3, 3, 3, 3, 2, 2, 1, 1];
      default: return [4, 3, 3, 3, 3, 2, 2, 1, 1];
    }
  }

  static List<int> _getWarlockSlots(int charLevel) {
    int count = 0;
    if (charLevel >= 1) count = 1;
    if (charLevel >= 2) count = 2;
    if (charLevel >= 11) count = 3;
    if (charLevel >= 17) count = 4;

    int slotLvl = 1;
    if (charLevel >= 3) slotLvl = 2;
    if (charLevel >= 5) slotLvl = 3;
    if (charLevel >= 7) slotLvl = 4;
    if (charLevel >= 9) slotLvl = 5;

    List<int> slots = List.filled(9, 0);

    if (count > 0) {
      slots[slotLvl - 1] = count;
    }

    if (charLevel >= 11) slots[5] = 1;
    if (charLevel >= 13) slots[6] = 1;
    if (charLevel >= 15) slots[7] = 1;
    if (charLevel >= 17) slots[8] = 1;

    return slots;
  }

  static bool isSpellcaster(String charClass, bool customMode) {
    if (customMode) return true;

    String cls = charClass.toLowerCase();
    const nonCasters = [
      'barbarian',
      'fighter',
      'monk',
      'rogue'
    ];

    return !nonCasters.contains(cls);
  }

  static String? canEquipItem(List<String> currentlyEquipped, String newItem) {
    String lowerNew = newItem.toLowerCase();
    bool isShield = lowerNew.contains("shield");
    bool isArmor = lowerNew.contains("(ac") && !isShield;
    bool isWeapon = lowerNew.contains("1d") || lowerNew.contains("2d") || lowerNew.contains("3d");
    bool isNewTwoHanded = lowerNew.contains("two-handed");

    if (isArmor) {
      int armorCount = currentlyEquipped.where((i) {
        String lowerI = i.toLowerCase();
        return lowerI.contains("(ac") && !lowerI.contains("shield");
      }).length;
      if (armorCount >= 1) {
        return "You can only wear one piece of armor at a time!";
      }
    }

    if (isShield) {
      int shieldCount = currentlyEquipped.where((i) {
        String lowerI = i.toLowerCase();
        return lowerI.contains("shield");
      }).length;
      if (shieldCount >= 1) {
        return "You already have a shield equipped!";
      }
      
      bool hasTwoHanded = currentlyEquipped.any((i) => i.toLowerCase().contains("two-handed"));
      if (hasTwoHanded) {
        return "Your hands are full with a two-handed weapon!";
      }
    }

    if (isWeapon) {
      var equippedWeapons = currentlyEquipped.where((i) =>
      i.contains("1d") || i.contains("2d") || i.contains("3d"));
      
      var equippedShields = currentlyEquipped.where((i) {
        String lowerI = i.toLowerCase();
        return lowerI.contains("shield");
      });

      int occupiedMains = equippedWeapons.length + equippedShields.length;
      bool hasTwoHandedEquipped = equippedWeapons.any((w) =>
          w.toLowerCase().contains("two-handed"));

      if (isNewTwoHanded) {
        if (occupiedMains > 0) {
          return "You need both hands free for this weapon!";
        }
      } else {
        if (hasTwoHandedEquipped) {
          return "Your hands are full with a two-handed weapon!";
        }
        if (occupiedMains >= 2) {
          return "Your hands are already full (Max 2 items between weapons and shield)!";
        }
      }
    }
    return null;
  }
}

