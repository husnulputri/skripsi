import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends NyStatefulWidget {
  static RouteView path = ("/admin-dashboard", (_) => AdminDashboardPage());

  AdminDashboardPage({super.key})
      : super(child: () => _AdminDashboardPageState());
}

class _AdminDashboardPageState extends NyPage<AdminDashboardPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> approveUser(String userId) async {
    await users.doc(userId).update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ User berhasil disetujui!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F6), // greenish white
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC7B3),
        elevation: 0,
        title: Text(
          "🌸 Admin Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.where('approved', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Terjadi kesalahan.'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          if (data.docs.isEmpty) {
            return Center(
              child: Text(
                '✨ Tidak ada user yang perlu disetujui.',
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                final doc = data.docs[index];
                final user = doc.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE0F2F1),
                      child:
                          Icon(Icons.person_outline, color: Colors.teal[700]),
                    ),
                    title: Text(
                      user['name'] ?? 'Nama tidak tersedia',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user['email'] ?? '',
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => approveUser(doc.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC7B3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Setujui",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
