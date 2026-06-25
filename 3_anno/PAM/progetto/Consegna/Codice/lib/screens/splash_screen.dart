import 'dart:async';
import 'package:flutter/material.dart';
import '../services/dnd_api_services.dart';
import 'home_screen.dart';
import '../core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DndApiService _api = DndApiService();
  double _progress = 0.0;
  String _loadingText = "Inizializzazione...";

  @override
  void initState() {
    super.initState();
    _startLoadingProcess();
  }

  Future<void> _startLoadingProcess() async {
    // Phase 1: Initial Check
    _updateStatus("Checking connection...", 0.1);
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 2: Weapons
    _updateStatus("Forging weapons...", 0.3);
    // forceRefresh: true ensures we always download the most recent data on startup
    await _api.getAllWeapons(); //forceRefresh: true

    // Phase 3: Armor
    _updateStatus("Reinforcing shields...", 0.5);
    await _api.getAllArmor(); //forceRefresh: true

    // Phase 4: Magic Items
    _updateStatus("Enchanting rings...", 0.7);
    await _api.getAllMagicItems(); //forceRefresh: true

    // Phase 5: Spells - The largest part
    _updateStatus("Writing the Grimoire...", 0.9);
    await _api.getAllSpells(); //forceRefresh: true

    // Completed
    _updateStatus("Ready!", 1.0);
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to Home
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _updateStatus(String text, double value) {
    setState(() {
      _loadingText = text;
      _progress = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Sfondo scuro
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Contenuto Centrale
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.logo,
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                "CRUCIBLE",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                  color: Colors.white,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 100), // Spazio per la barra
            ],
          ),

          // Barra di Caricamento in Basso
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loadingText,
                  style: const TextStyle(color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[800],
                    color: Colors.redAccent,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${(_progress * 100).toInt()}%",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}