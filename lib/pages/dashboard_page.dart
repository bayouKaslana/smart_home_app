import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/mqtt_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final mqtt = MQTTService();

  bool mqttConnected = false; // ⭐ Tambahan

  SensorData data = SensorData(
    temperature: 0,
    humidity: 0,
    gasDetected: true,
  );

  @override
  void initState() {
    super.initState();

    // Callback data sensor
    mqtt.onDataReceived = (newData) {
      setState(() => data = newData);
    };

    // ⭐ Callback status koneksi MQTT
    mqtt.onConnectionChanged = (status) {
      setState(() => mqttConnected = status);
    };

    mqtt.connect();
  }

  Widget sensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    color: color,
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

  Widget gasStatusCard() {
    final bool safe = data.gasDetected;

    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              safe ? Icons.verified : Icons.warning_rounded,
              size: 38,
              color: safe ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Status Gas",
                    style: TextStyle(
                        fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: safe
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    safe ? "AMAN" : "GAS TERDETEKSI",
                    style: TextStyle(
                      color: safe ? Colors.green : Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Widget indikator koneksi
  Widget mqttStatusIndicator() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 14,
          color: mqttConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          mqttConnected ? "Connected" : "Disconnected",
          style: TextStyle(
            color: mqttConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Home Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
        actions: [
          mqttStatusIndicator(), // ⭐ dimasukkan ke AppBar
        ],
      ),

      backgroundColor: const Color(0xff111111),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            sensorCard(
              icon: Icons.thermostat,
              title: "Suhu",
              value: "${data.temperature.toStringAsFixed(1)} °C",
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            sensorCard(
              icon: Icons.water_drop,
              title: "Kelembapan",
              value: "${data.humidity.toStringAsFixed(1)} %",
              color: Colors.blue,
            ),
            const SizedBox(height: 15),
            gasStatusCard(),
          ],
        ),
      ),
    );
  }
}
