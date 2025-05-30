import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DahsboardPage extends NyStatefulWidget {
  static RouteView path = ("/dahsboard", (_) => DahsboardPage());

  DahsboardPage({super.key}) : super(child: () => _DahsboardPageState());
}

class _DahsboardPageState extends NyPage<DahsboardPage> {
  // Variables to store Firebase data
  double energy = 0.0;
  double voltage = 0.0;
  double power = 0.0;
  double current = 0.0;
  bool relayStatus = false;
  
  @override
  get init => () {
        // Initialize Firebase connection
        // _databaseRef = FirebaseDatabase.instance.ref('PZEM004T');
        // _listenToFirebaseChanges();
      };

  // void _listenToFirebaseChanges() {
  //   _databaseRef.onValue.listen((event) {
  //     if (event.snapshot.value != null) {
  //       final data = Map<String, dynamic>.from(event.snapshot.value as Map);
  //       setState(() {
  //         energy = (data['energy'] ?? 0.0).toDouble();
  //         voltage = (data['voltage'] ?? 0.0).toDouble();
  //         power = (data['power'] ?? 0.0).toDouble();
  //         current = (data['current'] ?? 0.0).toDouble();
  //         relayStatus = data['relay_state'] ?? false;
  //       });
  //     }
    // });
  // }

  double _calculatePercentage(double value, double maxValue) {
    return (value / maxValue * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'Anang Prayoga',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: const Icon(Icons.person, color: Colors.purple),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Realtime Monitoring Title
                const Text(
                  'Realtime Monitoring',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Monitoring Grid
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _buildMonitoringCard(
                      title: 'Energy',
                      value: '$energy Kwh',
                      color: Colors.orange,
                      gaugeValue: _calculatePercentage(
                          energy, 100), // Adjust max value as needed
                      icon: Icons.bolt,
                    ),
                    _buildMonitoringCard(
                      title: 'Tegangan',
                      value: '$voltage volt',
                      color: Colors.blue,
                      gaugeValue: _calculatePercentage(
                          voltage, 220), // Adjust max value as needed
                      icon: Icons.electric_bolt,
                    ),
                    _buildMonitoringCard(
                      title: 'Daya',
                      value: '$power watt',
                      color: Colors.green,
                      gaugeValue: _calculatePercentage(
                          power, 1000), // Adjust max value as needed
                      icon: Icons.power,
                    ),
                    _buildMonitoringCard(
                      title: 'Arus',
                      value: '$current A',
                      color: Colors.purple,
                      gaugeValue: _calculatePercentage(
                          current, 50), // Adjust max value as needed
                      icon: Icons.electric_meter,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Switch Home Section
                const Text(
                  'Swich home',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Relay Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Relay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Switch(
                          //   value: relayStatus,
                          //   onChanged: (value) {
                          //     // Update Firebase when relay is toggled
                          //     _databaseRef
                          //         .child('relay_state')
                          //         .set(value)
                          //         .then((_) {
                          //       setState(() {
                          //         relayStatus = value;
                          //       });
                          //     });
                          //   },
                          //   activeColor: Colors.cyan,
                          // ),
                          
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tekan relay jika dalam keadaan darurat saja, ini akan memutus semua aliran listrik rumah',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringCard({
    required String title,
    required String value,
    required Color color,
    required double gaugeValue,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          showLabels: false,
                          showTicks: false,
                          startAngle: 270,
                          endAngle: 270,
                          radiusFactor: 1,
                          axisLineStyle: AxisLineStyle(
                            thickness: 10,
                            color: color.withOpacity(0.2),
                            thicknessUnit: GaugeSizeUnit.logicalPixel,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: gaugeValue,
                              width: 10,
                              color: color,
                              enableAnimation: true,
                              cornerStyle: CornerStyle.bothCurve,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      icon,
                      color: color,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}