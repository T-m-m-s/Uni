import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importazioni dei tuoi file
import 'providers/character_provider.dart';
import 'screens/home_screen.dart';

void main() {
  // Assicura che i binding di Flutter siano inizializzati
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // SETUP PROVIDER:
    // Avvolgiamo l'app in ChangeNotifierProvider per gestire lo stato globale
    ChangeNotifierProvider(
      create: (context) => CharacterProvider(),
      child: const CrucibleApp(),
    ),
  );
}

class CrucibleApp extends StatelessWidget {
  const CrucibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crucible D&D',
      debugShowCheckedModeBanner: false,
      // Rimuove la scritta "Debug" in alto a destra

      // TEMA SCURO (Stile "Crucible")
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red[900],
        // Rosso scuro
        scaffoldBackgroundColor: const Color(0xFF121212),
        // Grigio quasi nero
        colorScheme: ColorScheme.dark(
          primary: Colors.redAccent,
          secondary: Colors.amber,
          surface: Colors.grey[900]!,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.grey[850],
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
      ), // Chiude ThemeData
      // PUNTO DI PARTENZA
      home: const HomeScreen(),
    ); // Chiude MaterialApp
  } // <--- Assicurati che ci sia questa
} // <--- E assicurati che ci sia questa finale
