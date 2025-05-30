import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/login/login_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterPage extends NyStatefulWidget {
  static RouteView path = ("/register", (_) => RegisterPage());

  RegisterPage({super.key}) : super(child: () => _RegisterPageState());
}

class _RegisterPageState extends NyPage<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  bool isButtonEnabled = false;

  void validateForm() {
    setState(() {
      isButtonEnabled = nameController.text.isNotEmpty ||
          emailController.text.isNotEmpty ||
          passwordController.text.isNotEmpty ||
          confirmPasswordController.text.isNotEmpty;
    });
  }

  void validateFields() {
    setState(() {
      nameError =
          nameController.text.isEmpty ? '* Nama tidak boleh kosong' : null;
      emailError = emailController.text.isEmpty
          ? '* Email atau nomor telepon tidak boleh kosong'
          : null;
      passwordError = passwordController.text.isEmpty
          ? '* Kata sandi tidak boleh kosong'
          : null;

      confirmPasswordError = confirmPasswordController.text.isEmpty
          ? '* Konfirmasi kata sandi tidak boleh kosong'
          : (confirmPasswordController.text != passwordController.text
              ? '* Kata sandi tidak cocok'
              : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SetColors.Putih,
      body: SafeArea(
        child: SingleChildScrollView(
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
              SizedBox(height: 5),
              Container(
                height: 55,
                width: 329,
                child: Text(
                  'Nikmati kemudahan mengelola pertanian dalam satu genggaman',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: SetColors.Hitam60Opacity,
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomTextField(
                  label: "Nama Lengkap",
                  controller: nameController,
                  errorText: nameError,
                  onChanged: validateForm),
              CustomTextField(
                  label: "Email atau Nomor Telepon",
                  controller: emailController,
                  errorText: emailError,
                  onChanged: validateForm),
              CustomTextField(
                  label: "Kata Sandi",
                  controller: passwordController,
                  errorText: passwordError,
                  obscureText: true,
                  onChanged: validateForm,
                  isPasswordField: true),
              CustomTextField(
                  label: "Konfirmasi Kata Sandi",
                  controller: confirmPasswordController,
                  errorText: confirmPasswordError,
                  obscureText: true,
                  onChanged: validateForm,
                  isPasswordField: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  validateFields(); // Validasi input
                  if (nameError == null &&
                      emailError == null &&
                      passwordError == null &&
                      confirmPasswordError == null) {
                    try {
                      await AuthService().register(
                        email: emailController.text,
                        password: passwordController.text,
                        name: nameController.text,
                        context: context,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Pendaftaran gagal: ${e.toString()}')),
                      );
                    }
                  }
                },
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
                  'Daftar',
                  style: GoogleFonts.kaiseiHarunoUmi(
                    textStyle: TextStyle(
                      color: Colors.white,
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
                    text: "Sudah Punya Akun? ",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Log in",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SetColors.Hitam,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            routeTo(LoginPage.path);
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30), // Tambahan spacing di bawah
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final bool obscureText;
  final Function()? onChanged;
  final bool isPasswordField;

  CustomTextField({
    required this.label,
    required this.controller,
    this.errorText,
    this.obscureText = false,
    this.onChanged,
    this.isPasswordField = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFilled = widget.controller.text.isNotEmpty;
    bool hasError = widget.errorText != null;
    Color activeColor = SetColors.Hijau;
    Color errorColor = SetColors.Merah;
    Color defaultColor = SetColors.Hijau60Opacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: hasError
                ? (_isFocused
                    ? activeColor
                    : errorColor) // Jika error dan difokuskan, hijau
                : (_isFocused || isFilled)
                    ? activeColor
                    : defaultColor,
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: widget.controller,
          obscureText:
              widget.isPasswordField ? !_isPasswordVisible : widget.obscureText,
          focusNode: _focusNode,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            errorText: widget.errorText,
            errorMaxLines: 2,
            errorStyle: TextStyle(
                color: SetColors.Merah,
                fontSize: 8,
                fontWeight: FontWeight.w500),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: hasError
                      ? errorColor
                      : (isFilled ? activeColor : defaultColor)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: hasError ? errorColor : activeColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: errorColor, width: 2), // Ditambahkan
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: errorColor, width: 2), // Ditambahkan
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: widget.isPasswordField
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: hasError
                          ? SetColors.Merah
                          : (_isFocused || widget.controller.text.isNotEmpty)
                              ? SetColors.Hijau
                              : SetColors.Hijau60Opacity,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              if (widget.errorText != null && value.isNotEmpty) {}
            });

            if (widget.onChanged != null) {
              widget.onChanged!();
            }
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
