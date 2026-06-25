import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

class RaceSearch extends StatefulWidget {
  const RaceSearch({super.key});

  static Future<Map<String, dynamic>?> showRaceSearch(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const RaceSearch(),
    );
  }

  @override
  State<RaceSearch> createState() => _RaceSearchState();
}

class _RaceSearchState extends State<RaceSearch> {
  final DndApiService _apiService = DndApiService();
  List<dynamic> _allRaces = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  void _loadRaces() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    var races = await _apiService.getAllRaces();

    if (!extensionsEnabled) {
      races = races.where((r) => r['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;
    setState(() {
      _allRaces = races;
      _filteredResults = races;
      _isLoading = false;
    });
  }

  void _filterList(String query) {
    setState(() {
      _filteredResults = _allRaces
          .where((race) => race['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Choose Race", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Search race...",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              onChanged: _filterList,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _filteredResults.length,
                      separatorBuilder: (ctx, i) => const Divider(color: Colors.white10),
                      itemBuilder: (ctx, index) {
                        final race = _filteredResults[index];
                        return ListTile(
                          title: Text(race['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            race['desc'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => Navigator.pop(context, race),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
