// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_app/config/assets_image.dart';
// import 'package:flutter_app/config/colors_config.dart';
// import 'package:nylo_framework/nylo_framework.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
// import 'package:numberpicker/numberpicker.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database

// class HomePage extends NyStatefulWidget {
//   static RouteView path = ("/home", (_) => HomePage());

//   HomePage({super.key}) : super(child: () => _HomePageState());
// }

// class _HomePageState extends NyPage<HomePage> {
//   bool isManual = false;
//   bool isAutomatic = false;
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   bool isLightOn = false;
//   bool isAutoMode = false;
//   double suhuUdara = 27;
//   double lightIntensity = 100;
//   double kelembapan = 500;
//   int selectedDuration = 1; // Durasi default
//   List<Map<String, dynamic>> schedules = [
//     {'startTime': TimeOfDay.now(), 'duration': 1},
//   ]; // Awalnya ada satu kolom

//   // User info variables
//   String userName = 'User';
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Firebase Realtime Database reference
//   final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

//   // Stream subscriptions for real-time data
//   late StreamSubscription<DatabaseEvent> _suhuUdaraSubscription;
//   late StreamSubscription<DatabaseEvent> _lightIntensitySubscription;
//   late StreamSubscription<DatabaseEvent> _kelembapanSubscription;

//   void _addSchedule() {
//     if (schedules.length < 3) {
//       // Maksimal 3 penjadwalan
//       setState(() {
//         schedules.add({
//           'startTime': TimeOfDay.now(),
//           'duration': 1,
//         });
//       });
//     }
//   }

//   // Get current user name
//   void _getCurrentUser() {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       // Check if display name exists
//       if (user.displayName != null && user.displayName!.isNotEmpty) {
//         setState(() {
//           userName = user.displayName!;
//         });
//       } else if (user.email != null) {
//         // Use email as fallback but remove domain part
//         final emailName = user.email!.split('@')[0];
//         setState(() {
//           userName = emailName;
//         });
//       }
//     }
//   }

//   // Set up Firebase Realtime Database listeners
//   void _setupDatabaseListeners() {
//     // Listen to Suhu Udara changes
//     _suhuUdaraSubscription =
//         _databaseReference.child('sensor/suhuUdara').onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           // Parse the value to double
//           suhuUdara = double.parse(event.snapshot.value.toString());
//         });
//       }
//     });

//     // Listen to Light Intensity changes
//     _lightIntensitySubscription = _databaseReference
//         .child('sensor/lightIntensity')
//         .onValue
//         .listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           // Parse the value to double
//           lightIntensity = double.parse(event.snapshot.value.toString());
//         });
//       }
//     });

//     // Listen to Kelembapan changes
//     _kelembapanSubscription =
//         _databaseReference.child('sensor/kelembapan').onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           // Parse the value to double
//           kelembapan = double.parse(event.snapshot.value.toString());
//         });
//       }
//     });

//     // You can also listen to additional data like isLightOn status
//     _databaseReference.child('controls/isLightOn').onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           isLightOn = event.snapshot.value as bool;
//         });
//       }
//     });

//     _databaseReference.child('controls/isAutoMode').onValue.listen((event) {
//       if (event.snapshot.value != null) {
//         setState(() {
//           isAutoMode = event.snapshot.value as bool;
//         });
//       }
//     });
//   }

//   // Update control values to Firebase
//   void updateLightStatus(bool value) {
//     _databaseReference.child('controls/isLightOn').set(value);
//     setState(() {
//       isLightOn = value;
//     });
//   }

//   void updateAutoMode(bool value) {
//     _databaseReference.child('controls/isAutoMode').set(value);
//     setState(() {
//       isAutoMode = value;
//       if (isAutoMode) {
//         isLightOn = true;
//       }
//     });
//   }

//   // Update irrigation control to Firebase
//   void _updateIrrigationControl() {
//     if (isManual) {
//       _databaseReference.child('irrigation/mode').set('manual');
//       // Save schedules to Firebase
//       _databaseReference
//           .child('irrigation/schedules')
//           .set(schedules.map((schedule) {
//             return {
//               'startHour': schedule['startTime'].hour,
//               'startMinute': schedule['startTime'].minute,
//               'duration': schedule['duration'],
//             };
//           }).toList());
//     } else if (isAutomatic) {
//       _databaseReference.child('irrigation/mode').set('automatic');
//     } else {
//       _databaseReference.child('irrigation/mode').set('off');
//     }
//   }

//   @override
//   void dispose() {
//     // Cancel stream subscriptions when the page is disposed
//     _suhuUdaraSubscription.cancel();
//     _lightIntensitySubscription.cancel();
//     _kelembapanSubscription.cancel();
//     super.dispose();
//   }

//   Future<void> showCupertinoTimePicker(
//       BuildContext context, int index, StateSetter setState) async {
//     TimeOfDay selectedTime = schedules[index]['startTime'];

//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext builder) {
//         return Center(
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: 300,
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Pilih Jam Mulai',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: SetColors.Hijau,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   SizedBox(
//                     height: 150,
//                     child: CupertinoTimerPicker(
//                       mode: CupertinoTimerPickerMode.hm,
//                       initialTimerDuration: Duration(
//                         hours: selectedTime.hour,
//                         minutes: selectedTime.minute,
//                       ),
//                       onTimerDurationChanged: (Duration newTime) {
//                         selectedTime = TimeOfDay(
//                           hour: newTime.inHours,
//                           minute: newTime.inMinutes % 60,
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         // Memastikan UI diperbarui
//                         schedules[index]['startTime'] = selectedTime;
//                       });
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: SetColors.Hijau,
//                     ),
//                     child: Text(
//                       "Simpan",
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: SetColors.Putih,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void toggleManual(bool value) {
//     setState(() {
//       isManual = value;
//       if (isManual) {
//         isAutomatic = false; // Matikan otomatis jika manual diaktifkan
//       }
//       _updateIrrigationControl();
//     });
//   }

//   void toggleAutomatic(bool value) {
//     setState(() {
//       isAutomatic = value;
//       if (isAutomatic) {
//         isManual = false; // Matikan manual jika otomatis diaktifkan
//       }
//       _updateIrrigationControl();
//     });
//   }

//   @override
//   get init => () {
//         // Get user info when page initializes
//         _getCurrentUser();
//         // Set up database listeners
//         _setupDatabaseListeners();

//         // Read initial values from Firebase
//         _databaseReference.child('irrigation/mode').get().then((snapshot) {
//           if (snapshot.exists) {
//             String mode = snapshot.value.toString();
//             setState(() {
//               isManual = mode == 'manual';
//               isAutomatic = mode == 'automatic';
//             });
//           }
//         });
//       };

//   @override
//   Widget view(BuildContext context) {
//     // The rest of your widget code remains the same
//     // Just update the onChanged callbacks to use our new Firebase methods

//     // For example, in your light control switch, use _updateLightStatus:
//     // Switch(
//     //   value: isLightOn,
//     //   onChanged: isAutoMode
//     //     ? null
//     //     : (bool value) {
//     //         _updateLightStatus(value);
//     //       },
//     // )

//     // And in your mode toggle:
//     // Switch(
//     //   value: isAutoMode,
//     //   onChanged: (value) {
//     //     _updateAutoMode(value);
//     //   },
//     // )

//     // In your manual/automatic toggles:
//     // Switch(
//     //   value: isManual,
//     //   onChanged: (bool value) {
//     //     toggleManual(value);
//     //   },
//     // )

//     // The rest of the view code remains the same as your original code
//     return Container(
//       decoration: BoxDecoration(
//         gradient: SetColors.backgroundHome,
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: SetColors.Putih,
//           toolbarHeight: 80,
//           title: Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Hello, $userName !', // Display user name here
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B4332),
//                     ),
//                   ),
//                   const Text(
//                     'Selamat Datang Di Buana Farm',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w300,
//                       color: Color(0xFF1B4332),
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               // User avatar - you could display profile image if available
//               CircleAvatar(
//                 backgroundColor: Colors.blue,
//                 radius: 20,
//                 child: _auth.currentUser?.photoURL != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.network(
//                           _auth.currentUser!.photoURL!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return const Icon(Icons.person,
//                                 color: Colors.white);
//                           },
//                         ),
//                       )
//                     : const Icon(Icons.person, color: Colors.white),
//               ),
//             ],
//           ),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),

//                   // Monitoring
//                   Container(
//                     decoration: BoxDecoration(
//                       color: SetColors.bgMonitoring,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Monitoring',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w500,
//                                 color: SetColors.Hijau,
//                               ),
//                             ),
//                             Text(
//                               DateTime.now()
//                                   .toString()
//                                   .split(' ')[0], // Current date
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w300,
//                                 color: SetColors.Hijau,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         // Monitoring Cards
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: buildGaugeCardAtas(
//                                     'Suhu Udara', // Judul
//                                     suhuUdara, // Nilai (double)
//                                     '°C', // Satuan
//                                     SetColors.biruMuda, // Warna gauge
//                                     AssetsImages.suhuUdara, // image
//                                     getKondisiSuhuUdara(suhuUdara), // Kondisi
//                                   ),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: buildGaugeCardAtas(
//                                     'Intensitas Cahaya', // Judul
//                                     lightIntensity, // Nilai (double)
//                                     'lux', // Satuan
//                                     SetColors.lightIntensity, // Warna gauge
//                                     AssetsImages.lightIntensity, // image
//                                     getKondisiCahaya(lightIntensity), // Kondisi
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: buildGaugeCardBawah(
//                                     'Kelembapan', // Judul
//                                     kelembapan, // Nilai (double)
//                                     '%', // Satuan
//                                     SetColors.kelembapanTanah, // Warna gauge
//                                     AssetsImages.kelembaban, // image
//                                     getKondisiKelembapan(kelembapan), // Kondisi
//                                   ),
//                                 ),
//                                 SizedBox(width: 12),
//                                 Expanded(
//                                   child: buildGaugeCardBawah(
//                                     'Light intensity', // Judul
//                                     lightIntensity, // Nilai (double)
//                                     'lux', // Satuan
//                                     SetColors.lightIntensity, // Warna gauge
//                                     AssetsImages.lightIntensity, // image
//                                     getKondisiCahaya(lightIntensity), // Kondisi
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: buildControlCard(),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Kontrol Penyiraman
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Text(
//                       'Kontrol Penyiraman :',
//                       style: TextStyle(
//                         fontSize: 23,
//                         fontWeight: FontWeight.w500,
//                         color: SetColors.Hitam,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 2),

//                   // Manual irrigation settings
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Switch Manual & Otomatis
//                         Container(
//                           height: 59,
//                           decoration: BoxDecoration(
//                             gradient: SetColors.backgroundMOnitoring,
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           child: Row(
//                             children: [
//                               // Switch Manual
//                               Expanded(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       'Manual',
//                                       style: TextStyle(
//                                         fontSize: 23,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 15),
//                                     Transform.scale(
//                                       scale: 1.1,
//                                       child: Switch(
//                                         value: isManual,
//                                         activeColor: SetColors.biruMuda,
//                                         inactiveThumbColor: SetColors.abuAbu,
//                                         inactiveTrackColor:
//                                             SetColors.abuAbu.withOpacity(0.5),
//                                         activeTrackColor:
//                                             SetColors.biruMuda.withOpacity(0.5),
//                                         overlayColor: MaterialStateProperty.all(
//                                             Colors.transparent),
//                                         trackOutlineColor:
//                                             MaterialStateProperty.resolveWith(
//                                                 (states) {
//                                           if (states.contains(
//                                               MaterialState.selected)) {
//                                             return SetColors.biruMuda;
//                                           }
//                                           return SetColors.abuAbu;
//                                         }),
//                                         onChanged: (bool value) {
//                                           toggleManual(value);
//                                         },
//                                         thumbIcon: MaterialStateProperty
//                                             .resolveWith<Icon?>(
//                                           (Set<MaterialState> states) {
//                                             if (states.contains(
//                                                 MaterialState.selected)) {
//                                               return Icon(Icons.water_drop,
//                                                   color: SetColors.Putih);
//                                             }
//                                             return Icon(Icons.water_drop,
//                                                 color: SetColors.Putih);
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // Garis Vertikal Pemisah
//                               SizedBox(
//                                 width: 4,
//                                 child: Container(
//                                   color: Colors.white,
//                                 ),
//                               ),

//                               // Switch Otomatis
//                               Expanded(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       'Otomatis',
//                                       style: TextStyle(
//                                         fontSize: 23,
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Transform.scale(
//                                       scale: 1.1,
//                                       child: Switch(
//                                         value: isAutomatic,
//                                         activeColor: SetColors.biruMuda,
//                                         inactiveThumbColor: SetColors.abuAbu,
//                                         inactiveTrackColor:
//                                             SetColors.abuAbu.withOpacity(0.5),
//                                         activeTrackColor:
//                                             SetColors.biruMuda.withOpacity(0.5),
//                                         overlayColor: MaterialStateProperty.all(
//                                             Colors.transparent),
//                                         trackOutlineColor:
//                                             MaterialStateProperty.resolveWith(
//                                                 (states) {
//                                           if (states.contains(
//                                               MaterialState.selected)) {
//                                             return SetColors.biruMuda;
//                                           }
//                                           return SetColors.abuAbu;
//                                         }),
//                                         onChanged: (bool value) {
//                                           toggleAutomatic(value);
//                                         },
//                                         thumbIcon: MaterialStateProperty
//                                             .resolveWith<Icon?>(
//                                           (Set<MaterialState> states) {
//                                             if (states.contains(
//                                                 MaterialState.selected)) {
//                                               return Icon(Icons.autorenew,
//                                                   color: SetColors.Putih);
//                                             }
//                                             return Icon(Icons.autorenew,
//                                                 color: SetColors.Putih);
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 24),

//                         // Pengaturan Penyiraman Manual (hanya jika Manual aktif)
//                         if (isManual) ...[
//                           Container(
//                             padding: const EdgeInsets.all(16.0),
//                             decoration: BoxDecoration(
//                               color: SetColors.bgMonitoring,
//                               borderRadius: BorderRadius.circular(15.0),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Menggunakan Row agar teks dan tombol sejajar
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment
//                                       .spaceBetween, // Menjaga teks di kiri, tombol di kanan
//                                   children: [
//                                     const Text(
//                                       'Set waktu dan durasi penyiraman',
//                                       style: TextStyle(
//                                         fontSize: 23,
//                                         fontWeight: FontWeight.w500,
//                                         color: SetColors.Hitam,
//                                       ),
//                                     ),
//                                     if (schedules.length <
//                                         3) // Maksimal 3 penjadwalan
//                                       IconButton(
//                                         icon: Icon(Icons.add_circle,
//                                             color: SetColors.Hijau, size: 40),
//                                         onPressed: _addSchedule,
//                                       ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 20),

//                                 Column(
//                                   children:
//                                       List.generate(schedules.length, (index) {
//                                     return Padding(
//                                       padding:
//                                           const EdgeInsets.only(bottom: 16.0),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: _buildTimePicker(
//                                               context: context,
//                                               label: 'Jam mulai',
//                                               selectedTime: schedules[index]
//                                                   ['startTime'],
//                                               onTap: () =>
//                                                   showCupertinoTimePicker(
//                                                       context, index, setState),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Expanded(
//                                             child: _buildDurationPicker(
//                                               context: context,
//                                               label: "Durasi Penyiraman",
//                                               duration: schedules[index]
//                                                   ['duration'],
//                                               onChanged: (newDuration) {
//                                                 setState(() {
//                                                   schedules[index]['duration'] =
//                                                       newDuration ??
//                                                           schedules[index]
//                                                               ['duration'];
//                                                   _updateIrrigationControl(); // Update to Firebase
//                                                 });
//                                               },
//                                             ),
//                                           ),
//                                           if (schedules.length >
//                                               1) // Tampilkan tombol hapus jika lebih dari satu
//                                             IconButton(
//                                               icon: Icon(Icons.remove_circle,
//                                                   color: Colors.red),
//                                               onPressed: () {
//                                                 setState(() {
//                                                   schedules.removeAt(index);
//                                                   _updateIrrigationControl(); // Update to Firebase
//                                                 });
//                                               },
//                                             ),
//                                         ],
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper methods to determine conditions based on sensor values
//   String getKondisiSuhuUdara(double suhu) {
//     if (suhu < 20) {
//       return 'Dingin';
//     } else if (suhu >= 20 && suhu < 27) {
//       return 'Normal';
//     } else {
//       return 'Panas';
//     }
//   }

//   String getKondisiCahaya(double intensitas) {
//     if (intensitas < 50) {
//       return 'Gelap';
//     } else if (intensitas >= 50 && intensitas < 150) {
//       return 'Cukup';
//     } else {
//       return 'Terang';
//     }
//   }

//   String getKondisiKelembapan(double kelembapan) {
//     if (kelembapan < 300) {
//       return 'Kering';
//     } else if (kelembapan >= 300 && kelembapan < 700) {
//       return 'Normal';
//     } else {
//       return 'Basah';
//     }
//   }

//   // Widget untuk Card Monitoring dengan Gauge Atas
//   Widget buildGaugeCardAtas(
//     String title,
//     double value,
//     String unit,
//     Color gaugeColor,
//     String imagePath,
//     String kondisi,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: SetColors.backgroundMOnitoring,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w300,
//               color: SetColors.Putih,
//             ),
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: double.infinity,
//             height: 2,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.05),
//                   Colors.white.withOpacity(0.8),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 15),
//           Center(
//             child: Container(
//               child: Center(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       width: 90,
//                       height: 90,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         // border: Border.all(color: gaugeColor, width: 2),
//                       ),
//                       child: SfRadialGauge(
//                         axes: <RadialAxis>[
//                           RadialAxis(
//                             minimum: 0,
//                             maximum: 100,
//                             showLabels: false,
//                             showTicks: false,
//                             startAngle: 270,
//                             endAngle: 270,
//                             radiusFactor: 1,
//                             axisLineStyle: AxisLineStyle(
//                               thickness: 10,
//                               color: gaugeColor.withOpacity(0.2),
//                               thicknessUnit: GaugeSizeUnit.logicalPixel,
//                             ),
//                             pointers: <GaugePointer>[
//                               RangePointer(
//                                 value: value,
//                                 width: 15,
//                                 color: gaugeColor,
//                                 enableAnimation: true,
//                                 cornerStyle: CornerStyle.bothCurve,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Image.asset(
//                       imagePath,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Kondisi : $kondisi',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w300,
//                   color: SetColors.Putih,
//                 ),
//               ),
//               Text(
//                 'presentase : $value $unit',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w300,
//                   color: SetColors.Putih,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget untuk Card Monitoring dengan Gauge
//   Widget buildGaugeCardBawah(
//     String title,
//     double value,
//     String unit,
//     Color gaugeColor,
//     String imagePath,
//     String kondisi,
//   ) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: SetColors.backgroundMOnitoring,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w300,
//               color: SetColors.Putih,
//             ),
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           Container(
//             width: double.infinity,
//             height: 2,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.05),
//                   Colors.white.withOpacity(0.8),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Center(
//             child: Container(
//               child: Center(
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       width: 90,
//                       height: 90,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         // border: Border.all(color: gaugeColor, width: 2),
//                       ),
//                       child: SfRadialGauge(
//                         axes: <RadialAxis>[
//                           RadialAxis(
//                             minimum: 0,
//                             maximum: 100,
//                             showLabels: false,
//                             showTicks: false,
//                             startAngle: 270,
//                             endAngle: 270,
//                             radiusFactor: 1,
//                             axisLineStyle: AxisLineStyle(
//                               thickness: 10,
//                               color: gaugeColor.withOpacity(0.2),
//                               thicknessUnit: GaugeSizeUnit.logicalPixel,
//                             ),
//                             pointers: <GaugePointer>[
//                               RangePointer(
//                                 value: value,
//                                 width: 15,
//                                 color: gaugeColor,
//                                 enableAnimation: true,
//                                 cornerStyle: CornerStyle.bothCurve,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Image.asset(
//                       imagePath,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Kondisi : $kondisi',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w300,
//                   color: SetColors.Putih,
//                 ),
//               ),
//               Text(
//                 'presentase : $value $unit',
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w300,
//                   color: SetColors.Putih,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget untuk Kontrol Cahaya
//   Widget buildControlCard() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: SetColors.backgroundMOnitoring,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header yang lebih menarik
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Image.asset(AssetsImages.kontrolCahaya, width: 27),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'Kontrol Cahaya',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Garis pemisah yang lebih halus
//           Container(
//             width: double.infinity,
//             height: 2,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.white.withOpacity(0.05),
//                   Colors.white.withOpacity(0.8),
//                   Colors.white.withOpacity(0.05),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 25),

//           // Toggle Otomatis/Manual dengan animasi
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       isAutoMode ? Icons.auto_fix_high : Icons.touch_app,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Mode: ',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       isAutoMode ? 'Otomatis' : 'Manual',
//                       style: TextStyle(
//                         color: isAutoMode
//                             ? SetColors.lightIntensity
//                             : Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Switch(
//                   value: isAutoMode,
//                   activeColor: SetColors.lightIntensity,
//                   inactiveThumbColor: SetColors.abuAbu,
//                   trackOutlineColor:
//                       MaterialStateProperty.all(Colors.transparent),
//                   onChanged: (value) {
//                     setState(() {
//                       isAutoMode = value;
//                       if (isAutoMode) {
//                         isLightOn = true;
//                       }
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 15),

//           // Switch untuk kontrol lampu yang lebih menarik
//           Center(
//             child: Column(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isLightOn
//                         ? SetColors.lightIntensity.withOpacity(0.2)
//                         : Colors.white.withOpacity(0.1),
//                     boxShadow: isLightOn
//                         ? [
//                             BoxShadow(
//                               color: SetColors.lightIntensity.withOpacity(0.5),
//                               blurRadius: 30,
//                               spreadRadius: 5,
//                             )
//                           ]
//                         : null,
//                   ),
//                   child: Center(
//                     child: Transform.scale(
//                         scale: 1.0,
//                         child: Switch(
//                           value: isLightOn,
//                           activeColor: SetColors.lightIntensity,
//                           inactiveThumbColor: SetColors.abuAbu,
//                           inactiveTrackColor: SetColors.abuAbu.withOpacity(0.3),
//                           activeTrackColor:
//                               SetColors.lightIntensity.withOpacity(0.5),
//                           overlayColor:
//                               MaterialStateProperty.all(Colors.transparent),
//                           trackOutlineColor:
//                               MaterialStateProperty.resolveWith((states) {
//                             // Pastikan warna tetap sama bahkan saat disabled (mode otomatis)
//                             if (isLightOn) {
//                               return SetColors.lightIntensity;
//                             }
//                             return SetColors.abuAbu;
//                           }),
//                           thumbColor:
//                               MaterialStateProperty.resolveWith((states) {
//                             // Pastikan warna thumb tetap sama meski disabled
//                             if (isLightOn) {
//                               return SetColors.lightIntensity;
//                             }
//                             return SetColors.abuAbu;
//                           }),
//                           onChanged: isAutoMode
//                               ? null // Tetap disabled saat mode otomatis
//                               : (bool value) {
//                                   setState(() {
//                                     isLightOn = value;
//                                   });
//                                 },
//                           thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
//                             (Set<MaterialState> states) {
//                               if (isLightOn) {
//                                 return Icon(Icons.lightbulb,
//                                     color: SetColors.Putih);
//                               }
//                               return Icon(Icons.lightbulb_outline,
//                                   color: SetColors.Putih);
//                             },
//                           ),
//                         )),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Status lampu yang lebih menarik
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: isLightOn
//                         ? SetColors.lightIntensity.withOpacity(0.3)
//                         : Colors.white.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: isLightOn
//                           ? SetColors.lightIntensity
//                           : Colors.white.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     isLightOn ? 'LAMPU MENYALA' : 'LAMPU MATI',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color:
//                           isLightOn ? SetColors.lightIntensity : Colors.white70,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 15),

//           // Tambahan keterangan jika otomatis
//           if (isAutoMode)
//             Center(
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: Colors.white70,
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Lampu menyala secara otomatis',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // Widget untuk Date Picker
// Widget _buildTimePicker({
//   required BuildContext context,
//   required String label,
//   required TimeOfDay selectedTime,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: InputDecorator(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey), // Warna default
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.green, width: 2), // Saat fokus
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: Colors.grey, width: 1), // Saat normal
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween, // Biar sejajar
//         children: [
//           Text(
//             '${selectedTime.hour}:${selectedTime.minute}',
//             style: TextStyle(fontSize: 18, color: SetColors.Hijau),
//           ),
//           Icon(Icons.access_time, color: SetColors.Hijau), // Icon jam di kanan
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildDurationPicker({
//   required BuildContext context,
//   required String label,
//   required int duration,
//   required ValueChanged<int?> onChanged,
// }) {
//   return GestureDetector(
//     onTap: () => _showNumberPicker(context, duration, onChanged),
//     child: InputDecorator(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: SetColors.Hijau),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: SetColors.Hijau, width: 2),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(color: SetColors.Hijau, width: 1),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "$duration detik",
//             style: TextStyle(fontSize: 18, color: SetColors.Hijau),
//           ),
//           Icon(Icons.timer, color: SetColors.Hijau),
//         ],
//       ),
//     ),
//   );
// }

// void _showNumberPicker(
//     BuildContext context, int initialDuration, ValueChanged<int?> onChanged) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       int selectedDuration = initialDuration;

//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             backgroundColor: SetColors.bgMonitoring,
//             title: Text(
//               "Pilih Durasi",
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: SetColors.Hijau),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 NumberPicker(
//                   value: selectedDuration,
//                   minValue: 1,
//                   maxValue: 240,
//                   haptics: true,
//                   selectedTextStyle: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: SetColors.Hijau,
//                   ),
//                   textStyle: TextStyle(
//                     fontSize: 18,
//                     color: SetColors.Hijau60Opacity,
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedDuration = value;
//                     });
//                   },
//                 ),
//                 Text(
//                   "Durasi: $selectedDuration detik",
//                   style: TextStyle(
//                     color: SetColors.Hijau,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   "Batal",
//                   style: TextStyle(
//                     color: SetColors.Hijau,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   onChanged(selectedDuration);
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   "OK",
//                   style: TextStyle(
//                     color: SetColors.Hijau,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }
