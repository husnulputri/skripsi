import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import for web detection
import 'package:flutter_app/config/colors_config.dart';
import 'package:flutter_app/resources/pages/login/login_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends NyStatefulWidget {
  static RouteView path = ("/logout", (_) => LogoutPage());

  LogoutPage({super.key}) : super(child: () => _LogoutPageState());
}

class _LogoutPageState extends NyPage<LogoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // User data state variables
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;
  String? _localImagePath; // Path untuk gambar yang disimpan lokal
  XFile? _webImageFile; // For web platform image handling

  @override
  get init => () {
        _fetchUserData();
        _loadLocalImage();
      };

  // Fetch user data from Firebase Auth
  void _fetchUserData() {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        setState(() {
          _userEmail = currentUser.email ?? '';
          _userName = currentUser.displayName ?? 'Pengguna';

          if (_userName == 'Pengguna' && currentUser.phoneNumber != null) {
            _userName = currentUser.phoneNumber!;
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'Pengguna';
          _userEmail = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
        _userName = 'Pengguna';
        _userEmail = '';
      });
    }
  }

  // Load image path dari shared preferences
  Future<void> _loadLocalImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid ?? 'default_user';
      final imagePath = prefs.getString('user_profile_image_$userId');
      
      if (imagePath != null) {
        if (kIsWeb) {
          // On web, we can't verify file existence, so just use the path
          setState(() {
            _localImagePath = imagePath;
          });
        } else {
          // On mobile platforms, check if file exists
          final file = File(imagePath);
          if (await file.exists()) {
            setState(() {
              _localImagePath = imagePath;
            });
          } else {
            prefs.remove('user_profile_image_$userId');
          }
        }
      }
    } catch (e) {
      print('Error loading local image: $e');
    }
  }

  // Simpan gambar secara lokal
  Future<void> _saveImageLocally(XFile imageFile) async {
    try {
      final userId = _auth.currentUser?.uid ?? 'default_user';
      
      if (kIsWeb) {
        // On web, store the XFile object and save reference
        setState(() {
          _webImageFile = imageFile;
          _localImagePath = imageFile.path; // For reference
        });
        
        // Save reference in SharedPreferences (though limited utility on web)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_image_$userId', imageFile.path);
      } else {
        // On mobile, use the original file path approach
        final selectedImagePath = imageFile.path;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile_image_$userId', selectedImagePath);
        
        setState(() {
          _localImagePath = selectedImagePath;
        });
      }
      
      print('Image saved locally at: ${imageFile.path}');
    } catch (e) {
      print('Error saving image locally: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan gambar')),
      );
    }
  }

  // Ambil gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? selectedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (selectedImage != null) {
        await _saveImageLocally(selectedImage);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memilih gambar')),
      );
    }
  }

  // Build profile image widget with platform-specific handling
  Widget _buildProfileImage() {
    if (kIsWeb) {
      // Web platform handling
      if (_webImageFile != null) {
        return Image.network(
          _webImageFile!.path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: SetColors.Putih,
              child: Icon(
                Icons.person,
                size: 80,
                color: SetColors.Hijau,
              ),
            );
          },
        );
      } else if (_localImagePath != null) {
        // Try to load as network image on web
        return Image.network(
          _localImagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: SetColors.Putih,
              child: Icon(
                Icons.person,
                size: 80,
                color: SetColors.Hijau,
              ),
            );
          },
        );
      }
    } else {
      // Mobile platform handling
      if (_localImagePath != null) {
        return Image.file(
          File(_localImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: SetColors.Putih,
              child: Icon(
                Icons.person,
                size: 80,
                color: SetColors.Hijau,
              ),
            );
          },
        );
      }
    }
    
    // Default fallback
    return Container(
      color: SetColors.Putih,
      child: Icon(
        Icons.person,
        size: 80,
        color: SetColors.Hijau,
      ),
    );
  }

  // Tampilkan dialog pilihan untuk ambil foto
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option - show on mobile, conditionally on web
                if (!kIsWeb)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.camera);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: SetColors.Hijau.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: SetColors.Hijau,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Kamera'),
                      ],
                    ),
                  ),
                // Gallery option
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: SetColors.Hijau.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 30,
                          color: SetColors.Hijau,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Galeri'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Function to handle logout
  Future<void> _performLogout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SetColors.Hijau,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: SetColors.backgroundMOnitoring,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Profile Image
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _buildProfileImage(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceOptions,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: SetColors.Hijau,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: SetColors.Putih,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Name and Email
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SetColors.Merah500Opacity,
                        foregroundColor: SetColors.Merah,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: SetColors.Merah,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: SetColors.Merah,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // App Version
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Polije Nursery',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: SetColors.Putih,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: SetColors.Hitam70Opacity,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[800],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Perform actual logout
                _performLogout().then((_) {
                  // Hide loading indicator
                  routeTo(LoginPage.path);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SetColors.Merah,
                foregroundColor: SetColors.Putih,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}