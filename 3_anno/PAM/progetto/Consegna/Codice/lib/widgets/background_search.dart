import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

class BackgroundSearch extends StatefulWidget {
  const BackgroundSearch({super.key});

  static Future<Map<String, dynamic>?> showBackgroundSearch(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const BackgroundSearch(),
    );
  }

  @override
  State<BackgroundSearch> createState() => _BackgroundSearchState();
}

class _BackgroundSearchState extends State<BackgroundSearch> {
  final DndApiService _apiService = DndApiService();
  List<dynamic> _allBackgrounds = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  void _loadBackgrounds() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    var backgrounds = await _apiService.getAllBackgrounds();

    if (!extensionsEnabled) {
      backgrounds = backgrounds.where((bg) => bg['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;
    setState(() {
      _allBackgrounds = backgrounds;
      _filteredResults = backgrounds;
      _isLoading = false;
    });
  }

  void _filterList(String query) {
    setState(() {
      _filteredResults = _allBackgrounds
          .where((bg) => bg['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Choose Background", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Search background...",
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
                        final bg = _filteredResults[index];
                        return ListTile(
                          title: Text(bg['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            bg['desc'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => Navigator.pop(context, bg),
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
