import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

class ClassSearch extends StatefulWidget {
  const ClassSearch({super.key});

  static Future<Map<String, dynamic>?> showClassSearch(BuildContext context) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const ClassSearch(),
    );
  }

  @override
  State<ClassSearch> createState() => _ClassSearchState();
}

class _ClassSearchState extends State<ClassSearch> {
  final DndApiService _apiService = DndApiService();
  List<dynamic> _allClasses = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    var classes = await _apiService.getAllClasses();

    if (!extensionsEnabled) {
      // Le classi base SRD/PHB in Open5e hanno spesso 'document__slug': 'wotc-srd'
      classes = classes.where((c) => c['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;
    setState(() {
      _allClasses = classes;
      _filteredResults = classes;
      _isLoading = false;
    });
  }

  void _filterList(String query) {
    setState(() {
      _filteredResults = _allClasses
          .where((c) => c['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Choose Class", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Search class...",
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
                        final c = _filteredResults[index];
                        return ListTile(
                          title: Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            c['desc'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => Navigator.pop(context, c),
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
