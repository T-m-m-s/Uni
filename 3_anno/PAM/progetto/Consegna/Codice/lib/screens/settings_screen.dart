import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "APPEARANCE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text("Dark Mode"),
                subtitle: const Text("Toggle the application's dark theme"),
                value: settings.isDarkMode,
                onChanged: (value) {
                  settings.toggleTheme(value);
                },
                secondary: Icon(
                  settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "CONTENT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text("Enable Extensions"),
                subtitle: const Text("Show content from various sources beyond the core manual (SRD)"),
                value: settings.extensionsEnabled,
                onChanged: (value) {
                  settings.setExtensionsEnabled(value);
                },
                secondary: const Icon(Icons.extension),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "INFO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const ListTile(
                title: Text("Version"),
                trailing: Text("1.0.0"),
              ),
              const ListTile(
                title: Text("Crucible D&D"),
                subtitle: Text("Created for true heroes."),
              ),
            ],
          );
        },
      ),
    );
  }
}
