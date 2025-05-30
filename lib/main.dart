import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/firebase_options.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:firebase_database/firebase_database.dart';

import 'bootstrap/boot.dart';

/// Nylo - Framework for Flutter Developers
/// Docs: https://nylo.dev/docs/6.x
/// Main entry point for the application.
void main() async {
  // Pastikan widget binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan penanganan error
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
        
      );
      FirebaseDatabase.instance.setLoggingEnabled(true);
      debugPrint("Firebase initialized successfully");
    } else {
      debugPrint("Firebase already initialized");
    }
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
    // Error ditangani, aplikasi akan terus berjalan
  }

  // Inisialisasi Nylo Framework
  await Nylo.init(
    setup: Boot.nylo,
    setupFinished: Boot.finished,
    showSplashScreen: true,
    // Uncomment showSplashScreen to show the splash screen
    // File: lib/resources/widgets/splash_screen.dart
  );
}
