import 'package:flutter/material.dart';
import 'package:flutter_app/config/colors_config.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';

class HistoryPage extends NyStatefulWidget {
  static RouteView path = ("/history", (_) => HistoryPage());

  HistoryPage({super.key}) : super(child: () => _HistoryPageState());
}

class _HistoryPageState extends NyPage<HistoryPage> {
  @override
  get init => () {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riwayat Aktivitas',
      debugShowCheckedModeBanner: false,
      home: const ActivityHistoryPage(),
    );
  }
}

abstract class ActivityRecord {
  final String type;
  final DateTime dateTime;
  final double temperature;
  final double soilHumidity;
  final double airHumidity;
  final double lightIntensity;

  ActivityRecord({
    required this.type,
    required this.dateTime,
    required this.temperature,
    required this.soilHumidity,
    required this.airHumidity,
    required this.lightIntensity,
  });

  IconData getActivityIcon();
  Color getActivityColor();
  String getActivityTitle();
  List<Widget> getActivityDetails(BuildContext context);

  Color getBackgroundColor() {
    return getActivityColor().withOpacity(0.1);
  }
}

class WateringRecord extends ActivityRecord {
  final String duration;

  WateringRecord({
    required String type,
    required DateTime dateTime,
    required this.duration,
    required double temperature,
    required double soilHumidity,
    required double airHumidity,
    required double lightIntensity,
  }) : super(
          type: type,
          dateTime: dateTime,
          temperature: temperature,
          soilHumidity: soilHumidity,
          airHumidity: airHumidity,
          lightIntensity: lightIntensity,
        );

  factory WateringRecord.fromFirebase(Map<dynamic, dynamic> data, String type) {
    try {
      // Prioritize readable_time if available
      if (data['readable_time'] != null) {
        try {
          final dateFormat = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID');
          final dateTime = dateFormat.parse(data['readable_time'] as String);

          // Extract duration
          int durationSeconds = data['duration'] as int? ?? 0;
          String formattedDuration = durationSeconds >= 60
              ? '${durationSeconds ~/ 60} menit ${durationSeconds % 60 > 0 ? '${durationSeconds % 60} detik' : ''}'
              : '$durationSeconds detik';

          // Extract sensor values
          Map<dynamic, dynamic> sensorValues = data['sensor_values'] ?? {};
          return WateringRecord(
            type: type == 'auto' ? 'Otomatis' : 'Manual',
            dateTime: dateTime,
            duration: formattedDuration.trim(),
            temperature:
                (sensorValues['temperature'] as num?)?.toDouble() ?? 0.0,
            soilHumidity:
                (sensorValues['soil_moisture'] as num?)?.toDouble() ?? 0.0,
            airHumidity: (sensorValues['humidity'] as num?)?.toDouble() ?? 0.0,
            lightIntensity:
                (sensorValues['light_intensity'] as num?)?.toDouble() ?? 0.0,
          );
        } catch (e) {
          print('Error parsing readable_time: $e');
        }
      }

      // Fallback to timestamp if readable_time not available
      int timestamp = data['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();

      // Extract duration
      int durationSeconds = data['duration'] as int? ?? 0;
      String formattedDuration = durationSeconds >= 60
          ? '${durationSeconds ~/ 60} menit ${durationSeconds % 60 > 0 ? '${durationSeconds % 60} detik' : ''}'
          : '$durationSeconds detik';

      // Extract sensor values
      Map<dynamic, dynamic> sensorValues = data['sensor_values'] ?? {};
      return WateringRecord(
        type: type == 'auto' ? 'Otomatis' : 'Manual',
        dateTime: dateTime,
        duration: formattedDuration.trim(),
        temperature: (sensorValues['temperature'] as num?)?.toDouble() ?? 0.0,
        soilHumidity:
            (sensorValues['soil_moisture'] as num?)?.toDouble() ?? 0.0,
        airHumidity: (sensorValues['humidity'] as num?)?.toDouble() ?? 0.0,
        lightIntensity:
            (sensorValues['light_intensity'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error creating WateringRecord: $e');
      return WateringRecord(
        type: type == 'auto' ? 'Otomatis' : 'Manual',
        dateTime: DateTime.now(),
        duration: '0 detik',
        temperature: 0.0,
        soilHumidity: 0.0,
        airHumidity: 0.0,
        lightIntensity: 0.0,
      );
    }
  }

  @override
  IconData getActivityIcon() =>
      type == 'Otomatis' ? Icons.autorenew : Icons.touch_app;

  @override
  Color getActivityColor() => type == 'Otomatis' ? Colors.blue : Colors.orange;

  @override
  String getActivityTitle() => 'Menyiram $type';

  @override
  List<Widget> getActivityDetails(BuildContext context) {
    return [
      Text(
        'Durasi: $duration',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ];
  }
}

class LightRecord extends ActivityRecord {
  final bool status;

  LightRecord({
    required String type,
    required DateTime dateTime,
    required this.status,
    required double temperature,
    required double soilHumidity,
    required double airHumidity,
    required double lightIntensity,
  }) : super(
          type: type,
          dateTime: dateTime,
          temperature: temperature,
          soilHumidity: soilHumidity,
          airHumidity: airHumidity,
          lightIntensity: lightIntensity,
        );

  factory LightRecord.fromFirebase(Map<dynamic, dynamic> data, String type) {
    try {
      // Prioritize readable_time if available
      if (data['readable_time'] != null) {
        try {
          final dateFormat = DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID');
          final dateTime = dateFormat.parse(data['readable_time'] as String);

          // Extract status
          bool status = data['status'] as bool? ?? false;

          // Extract sensor values
          Map<dynamic, dynamic> sensorValues = data['sensor_values'] ?? {};
          return LightRecord(
            type: type == 'auto' ? 'Otomatis' : 'Manual',
            dateTime: dateTime,
            status: status,
            temperature:
                (sensorValues['temperature'] as num?)?.toDouble() ?? 0.0,
            soilHumidity:
                (sensorValues['soil_moisture'] as num?)?.toDouble() ?? 0.0,
            airHumidity: (sensorValues['humidity'] as num?)?.toDouble() ?? 0.0,
            lightIntensity:
                (sensorValues['light_intensity'] as num?)?.toDouble() ?? 0.0,
          );
        } catch (e) {
          print('Error parsing readable_time: $e');
        }
      }

      // Fallback to timestamp if readable_time not available
      int timestamp = data['timestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();

      // Extract status
      bool status = data['status'] as bool? ?? false;

      // Extract sensor values
      Map<dynamic, dynamic> sensorValues = data['sensor_values'] ?? {};
      return LightRecord(
        type: type == 'auto' ? 'Otomatis' : 'Manual',
        dateTime: dateTime,
        status: status,
        temperature: (sensorValues['temperature'] as num?)?.toDouble() ?? 0.0,
        soilHumidity:
            (sensorValues['soil_moisture'] as num?)?.toDouble() ?? 0.0,
        airHumidity: (sensorValues['humidity'] as num?)?.toDouble() ?? 0.0,
        lightIntensity:
            (sensorValues['light_intensity'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error creating LightRecord: $e');
      return LightRecord(
        type: type == 'auto' ? 'Otomatis' : 'Manual',
        dateTime: DateTime.now(),
        status: false,
        temperature: 0.0,
        soilHumidity: 0.0,
        airHumidity: 0.0,
        lightIntensity: 0.0,
      );
    }
  }

  @override
  IconData getActivityIcon() =>
      type == 'Otomatis' ? Icons.auto_mode : Icons.touch_app;

  @override
  Color getActivityColor() => type == 'Otomatis' ? Colors.purple : Colors.amber;

  @override
  String getActivityTitle() => 'Lampu $type';

  @override
  List<Widget> getActivityDetails(BuildContext context) {
    return [
      Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: status ? Colors.amber[400] : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Kondisi: ${status ? "ON" : "OFF"}',
            style: TextStyle(
              color: status ? SetColors.Hijau : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ];
  }
}

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({Key? key}) : super(key: key);

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage>
    with SingleTickerProviderStateMixin {
  final List<ActivityRecord> allRecords = [];
  List<ActivityRecord> filteredRecords = [];
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  bool isCalendarVisible = false;
  bool isLoading = true;
  String errorMessage = '';
  String selectedActivityFilter = 'Semua';
  StreamSubscription? _wateringLogSubscription;
  StreamSubscription? _lightLogSubscription;
  StreamSubscription? _connectedSubscription;
  late TabController _tabController;
  bool _wateringDataReceived = false;
  bool _lightDataReceived = false;
  bool _isDisposed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isDisposed) _setupRealtimeListeners();
    });
  }

  void _handleTabSelection() {
    if (_isDisposed) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          selectedActivityFilter = 'Semua';
          break;
        case 1:
          selectedActivityFilter = 'Penyiraman';
          break;
        case 2:
          selectedActivityFilter = 'Pencahayaan';
          break;
      }
      _filterRecords();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelSubscriptions();
    _timeoutTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _wateringLogSubscription?.cancel();
    _lightLogSubscription?.cancel();
    _connectedSubscription?.cancel();
  }

  void _setupRealtimeListeners() {
    if (_isDisposed) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
      _wateringDataReceived = false;
      _lightDataReceived = false;
    });

    try {
      final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
      _connectedSubscription = connectedRef.onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (!connected && mounted && !_isDisposed) {
          setState(() {
            errorMessage =
                'Tidak dapat terhubung ke Firebase. Periksa koneksi internet Anda.';
            isLoading = false;
          });
        }
      }, onError: (error) {
        _handleError('Kesalahan koneksi Firebase: $error');
      });

      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (isLoading && mounted && !_isDisposed) {
          setState(() {
            if (!_wateringDataReceived && !_lightDataReceived) {
              errorMessage = 'Tidak dapat mengambil data: Timeout';
              isLoading = false;
            }
          });
        }
      });

      final wateringRef = FirebaseDatabase.instance.ref('watering_log');
      _wateringLogSubscription = wateringRef.onValue.listen(
        (event) {
          if (_isDisposed) return;
          _wateringDataReceived = true;
          if (!mounted) return;
          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            if (data != null) _processWateringData(data);
          }
          _checkLoadingComplete();
        },
        onError: (error) {
          _handleError('Error saat mengambil data penyiraman: $error');
          _wateringDataReceived = true;
        },
      );

      final lightRef = FirebaseDatabase.instance.ref('light_log');
      _lightLogSubscription = lightRef.onValue.listen(
        (event) {
          if (_isDisposed) return;
          _lightDataReceived = true;
          if (!mounted) return;
          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            if (data != null) _processLightData(data);
          }
          _checkLoadingComplete();
        },
        onError: (error) {
          _handleError('Error saat mengambil data pencahayaan: $error');
          _lightDataReceived = true;
        },
      );
    } catch (e) {
      _handleError('Error: Tidak dapat mengambil data: $e');
    }
  }

  void _checkLoadingComplete() {
    if (_isDisposed) return;
    if (_wateringDataReceived && _lightDataReceived && mounted) {
      setState(() {
        isLoading = false;
        _timeoutTimer?.cancel();
      });
    }
  }

  void _handleError(String error) {
    if (_isDisposed) return;
    if (mounted) {
      setState(() {
        errorMessage = error;
        isLoading = false;
      });
    }
  }

  void _processWateringData(Map<dynamic, dynamic> data) {
    if (_isDisposed) return;
    try {
      List<ActivityRecord> newWateringRecords = [];
      if (data.containsKey('auto') && data['auto'] is Map) {
        final autoData = data['auto'] as Map<dynamic, dynamic>;
        int count = 0;
        int maxRecords = 50;
        autoData.forEach((key, value) {
          if (count >= maxRecords) return;
          if (value is Map) {
            try {
              newWateringRecords
                  .add(WateringRecord.fromFirebase(value, 'auto'));
              count++;
            } catch (e) {
              print('Error processing auto watering record: $e');
            }
          }
        });
      }
      if (data.containsKey('manual') && data['manual'] is Map) {
        final manualData = data['manual'] as Map<dynamic, dynamic>;
        int count = 0;
        int maxRecords = 50;
        manualData.forEach((key, value) {
          if (count >= maxRecords) return;
          if (value is Map) {
            try {
              newWateringRecords
                  .add(WateringRecord.fromFirebase(value, 'manual'));
              count++;
            } catch (e) {
              print('Error processing manual watering record: $e');
            }
          }
        });
      }
      if (mounted && !_isDisposed) {
        setState(() {
          allRecords.removeWhere((record) => record is WateringRecord);
          allRecords.addAll(newWateringRecords);
          _sortAndFilterRecords();
        });
      }
    } catch (e) {
      print('Error in _processWateringData: $e');
    }
  }

  void _processLightData(Map<dynamic, dynamic> data) {
    if (_isDisposed) return;
    try {
      List<ActivityRecord> newLightRecords = [];
      if (data.containsKey('auto') && data['auto'] is Map) {
        final autoData = data['auto'] as Map<dynamic, dynamic>;
        int count = 0;
        int maxRecords = 50;
        autoData.forEach((key, value) {
          if (count >= maxRecords) return;
          if (value is Map) {
            try {
              newLightRecords.add(LightRecord.fromFirebase(value, 'auto'));
              count++;
            } catch (e) {
              print('Error processing auto light record: $e');
            }
          }
        });
      }
      if (data.containsKey('manual') && data['manual'] is Map) {
        final manualData = data['manual'] as Map<dynamic, dynamic>;
        int count = 0;
        int maxRecords = 50;
        manualData.forEach((key, value) {
          if (count >= maxRecords) return;
          if (value is Map) {
            try {
              newLightRecords.add(LightRecord.fromFirebase(value, 'manual'));
              count++;
            } catch (e) {
              print('Error processing manual light record: $e');
            }
          }
        });
      }
      if (mounted && !_isDisposed) {
        setState(() {
          allRecords.removeWhere((record) => record is LightRecord);
          allRecords.addAll(newLightRecords);
          _sortAndFilterRecords();
        });
      }
    } catch (e) {
      print('Error in _processLightData: $e');
    }
  }

  void _sortAndFilterRecords() {
    if (_isDisposed) return;
    if (allRecords.isEmpty) {
      filteredRecords = [];
      return;
    }
    try {
      allRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _filterRecords();
    } catch (e) {
      print('Error in _sortAndFilterRecords: $e');
    }
  }

  void _filterRecords() {
    if (_isDisposed) return;
    try {
      List<ActivityRecord> dateFiltered =
          _filterRecordsByDateRange(allRecords, selectedDateRange);
      if (selectedActivityFilter == 'Penyiraman') {
        filteredRecords =
            dateFiltered.where((record) => record is WateringRecord).toList();
      } else if (selectedActivityFilter == 'Pencahayaan') {
        filteredRecords =
            dateFiltered.where((record) => record is LightRecord).toList();
      } else {
        filteredRecords = dateFiltered;
      }
    } catch (e) {
      print('Error in _filterRecords: $e');
      filteredRecords = [];
    }
  }

  List<ActivityRecord> _filterRecordsByDateRange(
      List<ActivityRecord> records, DateTimeRange dateRange) {
    try {
      final startDate = DateTime(
          dateRange.start.year, dateRange.start.month, dateRange.start.day);
      final endDate = DateTime(dateRange.end.year, dateRange.end.month,
          dateRange.end.day, 23, 59, 59);
      return records.where((record) {
        return record.dateTime.isAfter(startDate) &&
            record.dateTime.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error in _filterRecordsByDateRange: $e');
      return [];
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (_isDisposed) return;
    if (args.value is PickerDateRange) {
      final PickerDateRange range = args.value;
      if (range.startDate != null && range.endDate != null) {
        setState(() {
          selectedDateRange = DateTimeRange(
            start: range.startDate!,
            end: range.endDate!,
          );
          _filterRecords();
        });
      }
    }
  }

  void _showDateRangePicker() {
    if (_isDisposed) return;
    setState(() {
      isCalendarVisible = !isCalendarVisible;
    });
  }

  String _getFormattedDateRange() {
    final startDate = DateFormat('dd MMM').format(selectedDateRange.start);
    final endDate = DateFormat('dd MMM').format(selectedDateRange.end);
    return '$startDate - $endDate';
  }

  Future<void> _refreshData() async {
    if (_isDisposed) return;
    _cancelSubscriptions();
    _timeoutTimer?.cancel();
    setState(() {
      allRecords.clear();
      filteredRecords.clear();
      errorMessage = '';
    });
    _setupRealtimeListeners();
  }

  @override
  Widget build(BuildContext context) {
    int totalActivities = filteredRecords.length;
    int wateringCount =
        filteredRecords.where((r) => r is WateringRecord).length;
    int lightCount = filteredRecords.where((r) => r is LightRecord).length;
    int automaticCount =
        filteredRecords.where((r) => r.type == 'Otomatis').length;
    int manualCount = filteredRecords.where((r) => r.type == 'Manual').length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SetColors.Hijau,
        title: const Text(
          'Riwayat Aktivitas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: SetColors.Putih,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: SetColors.Putih),
            onPressed: isLoading ? null : _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                gradient: SetColors.backgroundMOnitoring,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalActivities aktivitas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: _showDateRangePicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: SetColors.Hijau,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getFormattedDateRange(),
                                  style: const TextStyle(
                                    color: SetColors.Hijau,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  isCalendarVisible
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: SetColors.Hijau,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isCalendarVisible)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SetColors.Putih,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SfDateRangePicker(
                        onSelectionChanged: _onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.range,
                        initialSelectedRange: PickerDateRange(
                          selectedDateRange.start,
                          selectedDateRange.end,
                        ),
                        monthViewSettings:
                            const DateRangePickerMonthViewSettings(
                          firstDayOfWeek: 1,
                        ),
                        headerStyle: DateRangePickerHeaderStyle(
                          textStyle: TextStyle(
                            color: SetColors.Hijau,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        selectionColor: SetColors.Hijau,
                        startRangeSelectionColor: SetColors.Hijau,
                        endRangeSelectionColor: SetColors.Hijau,
                        rangeSelectionColor: SetColors.Hijau,
                        todayHighlightColor: SetColors.Hijau,
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          todayTextStyle:
                              const TextStyle(color: SetColors.Hijau),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      buildInfoCard(
                        icon: Icons.history,
                        title: 'Total Aktivity',
                        value: '$totalActivities',
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      buildInfoCard(
                        icon: Icons.water_drop,
                        title: 'Penyiraman',
                        value: '$wateringCount',
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      buildInfoCard(
                        icon: Icons.lightbulb,
                        title: 'Pencahayaan',
                        value: '$lightCount',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      buildInfoCard(
                        icon: Icons.auto_mode,
                        title: 'Otomatis',
                        value: '$automaticCount',
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      buildInfoCard(
                        icon: Icons.touch_app,
                        title: 'Manual',
                        value: '$manualCount',
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: SetColors.Hijau,
              unselectedLabelColor: Colors.grey,
              indicatorColor: SetColors.Hijau,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Penyiraman'),
                Tab(text: 'Pencahayaan'),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SetColors.Hijau,
                      ),
                    )
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 70,
                                color: SetColors.Hijau60Opacity,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: SetColors.Hijau60Opacity,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ElevatedButton(
                                onPressed: _refreshData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SetColors.Hijau,
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : filteredRecords.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    selectedActivityFilter == 'Penyiraman'
                                        ? Icons.water_drop_outlined
                                        : selectedActivityFilter ==
                                                'Pencahayaan'
                                            ? Icons.lightbulb_outline
                                            : Icons.history,
                                    size: 70,
                                    color: SetColors.Hijau60Opacity,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada data ${selectedActivityFilter.toLowerCase()}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: SetColors.Hijau60Opacity,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Coba pilih rentang tanggal yang berbeda',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: SetColors.Hijau60Opacity,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = filteredRecords[index];
                                bool showDate = index == 0 ||
                                    DateFormat('yyyy-MM-dd')
                                            .format(record.dateTime) !=
                                        DateFormat('yyyy-MM-dd').format(
                                            filteredRecords[index - 1]
                                                .dateTime);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDate)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, top: 8, bottom: 12),
                                        child: Text(
                                          DateFormat(
                                                  'EEEE, dd MMMM yyyy', 'id_ID')
                                              .format(record.dateTime),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: SetColors.Hijau,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  record.getBackgroundColor(),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: record
                                                        .getActivityColor()
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    record.getActivityIcon(),
                                                    color: record
                                                        .getActivityColor(),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            record
                                                                .getActivityTitle(),
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color: record
                                                                  .getActivityColor(),
                                                            ),
                                                          ),
                                                          Text(
                                                            'jam: ${DateFormat('HH:mm').format(record.dateTime)}',
                                                            style: TextStyle(
                                                              color: SetColors
                                                                  .Hitam60Opacity,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      ...record
                                                          .getActivityDetails(
                                                              context),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    _buildDetailItem(
                                                      icon: Icons.thermostat,
                                                      label: 'Suhu',
                                                      value:
                                                          '${record.temperature}°',
                                                      color: Colors.red[400]!,
                                                    ),
                                                    _buildDetailItem(
                                                      icon:
                                                          Icons.water_outlined,
                                                      label: 'Kelembapan tanah',
                                                      value:
                                                          '${record.soilHumidity}%',
                                                      color: Colors.blue[400]!,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    _buildDetailItem(
                                                      icon: Icons.wb_sunny,
                                                      label: 'Cahaya',
                                                      value:
                                                          '${record.lightIntensity} lux',
                                                      color: Colors.amber[400]!,
                                                    ),
                                                    _buildDetailItem(
                                                      icon: Icons.air,
                                                      label: 'Kelembapan udara',
                                                      value:
                                                          '${record.airHumidity}%',
                                                      color: Colors.teal[400]!,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(1.0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: SetColors.Hijau,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: SetColors.Hijau,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
