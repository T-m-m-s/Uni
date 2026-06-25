import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DndApiService {
  static const String _baseUrl = 'https://api.open5e.com/v1';

  // --- 1. INCANTESIMI (SPELLS) ---
  Future<List<dynamic>> getAllSpells({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Cache Check
    if (!forceRefresh && prefs.containsKey('cached_spells_v3')) {
      return json.decode(prefs.getString('cached_spells_v3')!);
    }

    // Download
    final url = Uri.parse('$_baseUrl/spells/?limit=2000');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> rawList = data['results'];

        // Rimozione Duplicati
        final uniqueList = _removeDuplicates(rawList);

        // Salvataggio Cache
        await prefs.setString('cached_spells_v3', json.encode(uniqueList));
        return uniqueList;
      }
      return [];
    } catch (e) {
      print('Errore Download Spell: $e');
      return [];
    }
  }

  // --- 2. ARMI (WEAPONS) ---
  Future<List<dynamic>> getAllWeapons({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && prefs.containsKey('cached_weapons_v3')) {
      return json.decode(prefs.getString('cached_weapons_v3')!);
    }

    final url = Uri.parse('$_baseUrl/weapons/?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);

        await prefs.setString('cached_weapons_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Armi: $e');
      return [];
    }
  }

  // --- 3. ARMATURE (ARMOR) ---
  Future<List<dynamic>> getAllArmor({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && prefs.containsKey('cached_armor_v3')) {
      return json.decode(prefs.getString('cached_armor_v3')!);
    }

    final url = Uri.parse('$_baseUrl/armor/?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);

        await prefs.setString('cached_armor_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Armature: $e');
      return [];
    }
  }

  // --- 4. OGGETTI MAGICI (MAGIC ITEMS) ---
  Future<List<dynamic>> getAllMagicItems({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && prefs.containsKey('cached_magicitems_v3')) {
      return json.decode(prefs.getString('cached_magicitems_v3')!);
    }

    final url = Uri.parse('$_baseUrl/magicitems/?limit=2000');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);

        await prefs.setString('cached_magicitems_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Magic Items: $e');
      return [];
    }
  }

  // --- 5. BACKGROUNDS ---
  Future<List<dynamic>> getAllBackgrounds({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && prefs.containsKey('cached_backgrounds_v3')) {
      return json.decode(prefs.getString('cached_backgrounds_v3')!);
    }

    final url = Uri.parse('$_baseUrl/backgrounds/?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);
        await prefs.setString('cached_backgrounds_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Backgrounds: $e');
      return [];
    }
  }

  // --- 6. FEATS ---
  Future<List<dynamic>> getAllFeats({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && prefs.containsKey('cached_feats_v3')) {
      return json.decode(prefs.getString('cached_feats_v3')!);
    }

    final url = Uri.parse('$_baseUrl/feats/?limit=200');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);
        await prefs.setString('cached_feats_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Feats: $e');
      return [];
    }
  }

  // --- 7. RACES ---
  Future<List<dynamic>> getAllRaces({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && prefs.containsKey('cached_races_v3')) {
      return json.decode(prefs.getString('cached_races_v3')!);
    }

    final url = Uri.parse('$_baseUrl/races/?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);
        await prefs.setString('cached_races_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Races: $e');
      return [];
    }
  }

  // --- 8. CLASSES ---
  Future<List<dynamic>> getAllClasses({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh && prefs.containsKey('cached_classes_v3')) {
      return json.decode(prefs.getString('cached_classes_v3')!);
    }

    final url = Uri.parse('$_baseUrl/classes/?limit=100');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = _removeDuplicates(data['results']);
        await prefs.setString('cached_classes_v3', json.encode(list));
        return list;
      }
      return [];
    } catch (e) {
      print('Errore Download Classes: $e');
      return [];
    }
  }

  // --- 9. SUBCLASSES ---
  Future<List<dynamic>> getSubclassesForClass(String classSlug) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_subclasses_${classSlug}_v3';

    // 1. Try Specific Cache
    if (prefs.containsKey(cacheKey)) {
      return json.decode(prefs.getString(cacheKey)!);
    }

    // 2. Try to search in already downloaded Class data (Optimization)
    try {
      final allClasses = await getAllClasses();
      if (allClasses.isNotEmpty) {
        final classData = allClasses.firstWhere(
          (c) => c['slug'].toString().toLowerCase() == classSlug.toLowerCase(),
          orElse: () => null,
        );
        if (classData != null && classData['archetypes'] != null) {
          final List<dynamic> archetypes = classData['archetypes'];
          await prefs.setString(cacheKey, json.encode(archetypes));
          return archetypes;
        }
      }
    } catch (e) {
      print('Local subclass search failed: $e');
    }

    // 3. Fallback: Download via API (v1 prefix already in _baseUrl)
    final url = Uri.parse('$_baseUrl/classes/$classSlug/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> archetypes = data['archetypes'] ?? [];
        await prefs.setString(cacheKey, json.encode(archetypes));
        return archetypes;
      }
      return [];
    } catch (e) {
      print('Error downloading Subclasses for $classSlug: $e');
      return [];
    }
  }

  // Mapping helper for Italian names to Open5e slugs
  String getClassSlug(String className) {
    final map = {
      // Italian
      'barbaro': 'barbarian',
      'bardo': 'bard',
      'chierico': 'cleric',
      'druido': 'druid',
      'guerriero': 'fighter',
      'monaco': 'monk',
      'paladino': 'paladin',
      'ranger': 'ranger',
      'ladro': 'rogue',
      'stregone': 'sorcerer',
      'warlock': 'warlock',
      'mago': 'wizard',
      // English equivalents are already handled by the case-insensitive lookup
      // or by the fallback below. Removing duplicates to satisfy linter.
    };
    final slug = map[className.toLowerCase()] ?? className.toLowerCase();
    return slug;
  }

  // --- HELPER PER RIMUOVERE DUPLICATI ---
  List<dynamic> _removeDuplicates(List<dynamic> rawList) {
    final seenNames = <String>{};
    final uniqueList = <dynamic>[];

    for (var item in rawList) {
      final name = item['name'].toString();
      if (!seenNames.contains(name)) {
        seenNames.add(name);
        uniqueList.add(item);
      }
    }
    return uniqueList;
  }
}