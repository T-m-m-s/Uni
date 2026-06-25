import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/character_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CharacterProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const CrucibleApp(),
    ),
  );
}

class CrucibleApp extends StatelessWidget {
  const CrucibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Crucible D&D',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
