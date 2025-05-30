import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/login/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/controllers/home_screen_controller.dart';

class HomeScreenPage extends NyStatefulWidget<HomeScreenController> {
  static RouteView path = ("/home-screen", (_) => HomeScreenPage());

  HomeScreenPage({super.key}) : super(child: () => _HomeScreenPageState());
}

class _HomeScreenPageState extends NyPage<HomeScreenPage> {
  /// [HomeScreenController] controller
  HomeScreenController get controller => widget.controller;

  @override
  get init => () {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // gambar Greenhouse
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                AssetsImages.greenHouse,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            // Title
            const Text(
              'Polije Nursery',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: SetColors.HijauSage,
              ),
            ),
            const SizedBox(height: 16),
            // Description text
            const Text(
              'App Polije Nursery memudahkan Anda merawat tanaman bunga krisan dengan teknologi IoT. Atur penyiraman dan pencahayaan otomatis, agar tanaman tetap sehat dan tumbuh optimal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.w500,
                color: SetColors.Hitam,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            // Mulai button
            SizedBox(
              width: double.infinity,
              height: 35,
              child: ElevatedButton(
                onPressed: () {
                  routeTo(LoginPage.path);
                  // routeTo(RegisterPage.path);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SetColors.Hijau,
                  foregroundColor: SetColors.Putih,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Mulai',
                  style: GoogleFonts.kaiseiHarunoUmi(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
