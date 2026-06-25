import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dnd_api_services.dart';
import '../providers/settings_provider.dart';

class SubclassSearch extends StatefulWidget {
  final String parentClass;
  const SubclassSearch({super.key, required this.parentClass});

  static Future<Map<String, dynamic>?> showSubclassSearch(BuildContext context, String parentClass) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => SubclassSearch(parentClass: parentClass),
    );
  }

  @override
  State<SubclassSearch> createState() => _SubclassSearchState();
}

class _SubclassSearchState extends State<SubclassSearch> {
  final DndApiService _apiService = DndApiService();
  List<dynamic> _allSubclasses = [];
  List<dynamic> _filteredResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubclasses();
  }

  void _loadSubclasses() async {
    final extensionsEnabled = Provider.of<SettingsProvider>(context, listen: false).extensionsEnabled;
    final slug = _apiService.getClassSlug(widget.parentClass);
    var subclasses = await _apiService.getSubclassesForClass(slug);

    if (!extensionsEnabled) {
      // Per le sottoclassi, filtriamo quelle che appartengono al documento SRD
      subclasses = subclasses.where((s) => s['document__slug'] == 'wotc-srd').toList();
    }

    if (!mounted) return;
    setState(() {
      _allSubclasses = subclasses;
      _filteredResults = _allSubclasses;
      _isLoading = false;
    });
  }

  void _filterList(String query) {
    setState(() {
      _filteredResults = _allSubclasses
          .where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: Text("Choose Subclass (${widget.parentClass})", 
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "Search subclass...",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
              ),
              onChanged: _filterList,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredResults.isEmpty 
                    ? const Center(child: Text("No subclasses found.", style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                      itemCount: _filteredResults.length,
                      separatorBuilder: (ctx, i) => Divider(color: isDark ? Colors.white10 : Colors.black12),
                      itemBuilder: (ctx, index) {
                        final s = _filteredResults[index];
                        return ListTile(
                          title: Text(s['name'], style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            s['desc'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => Navigator.pop(context, s),
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
