import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/admin/admin_dashboard_page.dart';
import 'package:flutter_app/resources/pages/dashboard/bottom_navigator/base_navigation_hub.dart';
import 'package:flutter_app/resources/pages/login/login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AuthService {
  Future<void> loginAdmin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Cek role admin di Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc['role'] != 'admin') {
        await FirebaseAuth.instance.signOut();
        _showErrorDialog(context, 'Hanya admin yang bisa login di sini');
        return;
      }

      routeTo(AdminDashboardPage.path);
    } catch (e) {
      _showErrorDialog(context, 'Login admin gagal: ${e.toString()}');
    }
  }

  Future<void> register(
      {required String email,
      required String password,
      required String name, // Add name parameter
      required BuildContext context}) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the user profile to include the display name (full name)
      await userCredential.user?.updateDisplayName(name);

      // Simpan data user ke Firestore dengan status approved: false
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': name,
        'email': email,
        'approved': false,
        'role': 'user', // default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optional: Reload user data to ensure we have the latest profile info
      // await userCredential.user?.reload();

      // Jika registrasi berhasil, tampilkan popup sukses
      _showSuccessDialog(
        context,
        'Registrasi berhasil! Akun Anda sedang menunggu validasi admin.',
        () => routeTo(LoginPage.path),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Kata sandi yang diberikan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Akun dengan email ini sudah terdaftar.';
      }
      // Tampilkan dialog error
      _showErrorDialog(context, message);
    } catch (e) {
      // Tampilkan dialog error umum
      _showErrorDialog(context, 'Terjadi kesalahan, coba lagi nanti.');
    }
  }

  // Login function with Firebase
  Future<void> masuk({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Cek status approved di Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (!userDoc.exists || userDoc['approved'] != true) {
        await FirebaseAuth.instance.signOut();
        _showErrorDialog(
          context,
          'Akun Anda belum divalidasi oleh admin. Silakan tunggu atau hubungi admin.',
        );
        return;
      }

      routeTo(BaseNavigationHub.path);
    } on FirebaseAuthException catch (e) {
      String message = '';

      // Better error message handling
      if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'user-not-found') {
        message = 'Email tidak terdaftar. Silakan daftar terlebih dahulu.';
      } else if (e.code == 'wrong-password') {
        message = 'Kata sandi yang dimasukkan salah.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau kata sandi salah.';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan.';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
      } else {
        message = 'Terjadi kesalahan: ${e.message}';
      }

      _showErrorDialog(context, message);
    } catch (e) {
      _showErrorDialog(context, 'Terjadi kesalahan, coba lagi nanti.');
    }
  }
  // // Logout function
  // Future<void> logout() async {
  //   await FirebaseAuth.instance.signOut();
  // }

  //popup dialog error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: SetColors.Putih,
          title: Row(
            children: [
              Icon(
                Icons.error,
                color: SetColors.Merah,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Error!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: SetColors.Merah),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16, color: SetColors.Hitam),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SetColors.Merah,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: SetColors.Putih),
              ),
            ),
          ],
        );
      },
    );
  }

  // popup dialog sukses
  void _showSuccessDialog(
      BuildContext context, String message, VoidCallback onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: SetColors.Putih,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: SetColors.Hijau, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Sukses!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16, color: SetColors.Hitam),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SetColors.Hijau,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onOkPressed();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: SetColors.Putih),
              ),
            ),
          ],
        );
      },
    );
  }
}
