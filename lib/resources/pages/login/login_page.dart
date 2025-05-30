import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/dashboard/bottom_navigator/base_navigation_hub.dart';
import 'package:flutter_app/resources/pages/register/register_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPage extends NyStatefulWidget {
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Controller untuk dialog lupa password
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  bool isButtonEnabled = false;
  bool isResettingPassword = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  get init => () {
        // Cek jika user sudah login sebelumnya
        if (_auth.currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            routeTo(BaseNavigationHub.path);
          });
        }
      };

  void validateFields() {
    setState(() {
      emailError = emailController.text.isEmpty
          ? '* Email atau nomor telepon tidak boleh kosong'
          : null;
      passwordError = passwordController.text.isEmpty
          ? '* Kata sandi tidak boleh kosong'
          : null;
      confirmPasswordError = confirmPasswordController.text.isEmpty
          ? '* Konfirmasi kata sandi tidak boleh kosong'
          : (confirmPasswordController.text != passwordController.text
              ? '* Konfirmasi kata sandi tidak sesuai dengan kata sandi'
              : null);
    });
  }

  // Fungsi untuk mengirim email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    setState(() {
      isResettingPassword = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: email);

      // Menampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Link reset password telah dikirim ke $email',
            style: TextStyle(
              color: SetColors.Putih,
            ),
          ),
          backgroundColor: SetColors.Hijau,
        ),
      );

      // Menutup dialog lupa password
      Navigator.of(context).pop();
    } catch (e) {
      // Menampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengirim email reset password: ${e.toString()}',
            style: TextStyle(
              color: SetColors.Putih,
            ),
          ),
          backgroundColor: SetColors.Merah,
        ),
      );
    } finally {
      setState(() {
        isResettingPassword = false;
      });
    }
  }

  // Menampilkan dialog untuk lupa password
  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SetColors.Hijau,
          title: Text(
            'Lupa Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: SetColors.Putih,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Masukkan email Anda untuk menerima link reset password',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              TextField(
                controller: forgotPasswordEmailController,
                style: TextStyle(color: SetColors.Putih),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: SetColors.Putih),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: SetColors.Putih),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: SetColors.Hijau),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isResettingPassword
                  ? null
                  : () {
                      if (forgotPasswordEmailController.text.isNotEmpty) {
                        sendPasswordResetEmail(
                            forgotPasswordEmailController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: SetColors.Hijau,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isResettingPassword
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Kirim',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.Putih,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text(
              'Polije Nursery',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: SetColors.Hitam,
              ),
            ),
            SizedBox(height: 20),
            CustomTextField(
                label: "Email atau Nomor Telepon",
                controller: emailController,
                errorText: emailError,
                onChanged: validateFields),
            CustomTextField(
                label: "Kata Sandi",
                controller: passwordController,
                errorText: passwordError,
                obscureText: true,
                onChanged: validateFields,
                isPasswordField: true),
            SizedBox(height: 10),
            // Tambahkan link Lupa Password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  showForgotPasswordDialog();
                },
                child: Text(
                  "Lupa Password?",
                  style: TextStyle(
                    color: SetColors.Hijau,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () async {
                      validateFields(); // Validasi input
                      if (emailError == null &&
                          passwordError == null &&
                          confirmPasswordError == null) {
                        try {
                          await AuthService().masuk(
                            email: emailController.text,
                            password: passwordController.text,
                            context: context,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Login gagal: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonEnabled
                    ? SetColors.Hijau
                    : SetColors.Hijau60Opacity,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.kaiseiHarunoUmi(
                  textStyle: TextStyle(
                    color: SetColors.Putih,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  text: "Belum punya akun? ",
                  style: TextStyle(
                    fontSize: 14,
                    color: SetColors.Hitam,
                  ),
                  children: [
                    TextSpan(
                      text: "Daftar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: SetColors.Hitam,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          routeTo(RegisterPage.path);
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
