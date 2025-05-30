import 'package:flutter/material.dart';

class SetColors {
  static const Color Putih = Colors.white;
  static const Color Hitam = Colors.black;
  static const Color Hitam60Opacity = Color(0x99000000);
  static const Color Hitam70Opacity = Color(0xB3000000);
  static const Color Hijau = Color(0xFF123524);
  static const Color Hijau60Opacity = Color(0x99123524);
  static const Color HijauSage = Color(0xFF3E7B27);
  static const Color Coklat = Color(0xFFEFE3C2);
  static const Color Merah = Color(0xFFF10000);
  static const Color Merah500Opacity = Color.fromARGB(65, 241, 0, 0);
  static const LinearGradient backgroundHome = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFC2FFC7),
    ],
    begin: Alignment.centerRight,
    end: Alignment.bottomCenter,
  );
  static const Color bgMonitoring = Color(0x99F5F3F3);
  static const Color biruMuda = Color(0xFF75B9F1);
  static const LinearGradient backgroundMOnitoring = LinearGradient(
    colors: [
      Color(0xFF359B69),
      Color(0xFF123524),
    ],
    begin: Alignment.centerRight,
    end: Alignment.bottomCenter,
  );
  static const Color lightIntensity = Color(0xFFF7B12D);
  static const Color kelembapanTanah = Color(0xFFC2FFC7);
  static const Color abuAbu = Colors.grey;
}
