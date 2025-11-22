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

  bool mqttConnected = false;

  // Tambahan: Status pintu
  bool doorLocked = false; // nanti bisa di-update via MQTT

  SensorData data = SensorData(
    temperature: 0,
    humidity: 0,
    gasDetected: true,
  );

  @override
  void initState() {
    super.initState();

    mqtt.onDataReceived = (newData) {
      setState(() => data = newData);
    };

    mqtt.onConnectionChanged = (status) {
      setState(() => mqttConnected = status);
    };

    mqtt.connect();
  }

  // =====================================================================
  // CARD SENSOR (SUHU & KELEMBAPAN)
  // =====================================================================
  Widget sensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // CARD STATUS GAS
  // =====================================================================
  Widget gasStatusCard() {
    final bool safe = data.gasDetected;

    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              safe ? Icons.verified : Icons.warning_amber_rounded,
              size: 36,
              color: safe ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Gas",
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: safe
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      safe ? "AMAN" : "GAS TERDETEKSI",
                      style: TextStyle(
                        color: safe ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // CARD STATUS PINTU
  // =====================================================================
  Widget doorStatusCard() {
    final bool locked = doorLocked;

    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              locked ? Icons.lock_open : Icons.lock,
              size: 36,
              color: locked ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Pintu",
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: locked
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      locked ? "OPEN" : "LOCK",
                      style: TextStyle(
                        color: locked ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // MQTT STATUS
  // =====================================================================
  Widget mqttStatusIndicator() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: mqttConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
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

  // =====================================================================
  // BUILD UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    final tempText = "${data.temperature.toStringAsFixed(1)} °C";
    final humText = "${data.humidity.toStringAsFixed(1)} %";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Home Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: mqttStatusIndicator(),
          ),
        ],
      ),
      backgroundColor: const Color(0xff0F0F10),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // SUHU & KELEMBAPAN
              Row(
                children: [
                  Expanded(
                    child: sensorCard(
                      icon: Icons.thermostat_outlined,
                      title: "Suhu",
                      value: tempText,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: sensorCard(
                      icon: Icons.water_drop_outlined,
                      title: "Kelembapan",
                      value: humText,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // GAS + PINTU BERDAMPINGAN
              Row(
                children: [
                  Expanded(child: gasStatusCard()),
                  const SizedBox(width: 12),
                  Expanded(child: doorStatusCard()),
                ],
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Terakhir update: ${DateTime.now().toLocal().toString().split('.').first}",
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
