import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/sensor_data.dart';
import '../services/mqtt_service.dart';
import 'add_user_page.dart';
import 'list_user_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  final mqtt = MQTTService();

  bool mqttConnected = false;

  // Tambahan: Status pintu
  bool doorLocked = true; // nanti bisa di-update via MQTT

  // Tambahan: status kipas
  bool fan1On = false;
  bool fan2On = false;

  late AnimationController fan1Ctrl;
  late AnimationController fan2Ctrl;

  SensorData data = SensorData(temperature: 0, humidity: 0, gas: 0, fan1: false, fan2: false, doorLocked: true);

 @override
void initState() {
  super.initState();

  fan1Ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  fan2Ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  // TEST: kipas ON → animasi harus langsung berputar
  if (fan1On) fan1Ctrl.repeat();
  if (fan2On) fan2Ctrl.repeat();

  // MQTT tetap jalan
  mqtt.onDataReceived = (newData) {
    setState(() {
      data = newData;

      fan1On = newData.fan1;
      fan2On = newData.fan2;

      fan1On ? fan1Ctrl.repeat() : fan1Ctrl.stop();
      fan2On ? fan2Ctrl.repeat() : fan2Ctrl.stop();

      doorLocked = newData.doorLocked;
    });
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
    final bool detected = data.gas > 1000;

    return Card(
      color: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              detected ? Icons.warning_amber_rounded : Icons.verified,
              size: 36,
              color: detected ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Gas",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: detected
                          ? Colors.red.withOpacity(0.12)
                          : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      detected ? "GAS TINGGI" : "AMAN",
                      style: TextStyle(
                        color: detected ? Colors.red : Colors.green,
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
              locked ? Icons.lock : Icons.lock_open,
              size: 36,
              color: locked ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Status Pintu",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: locked
                          ? Colors.red.withOpacity(0.12)
                          : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      locked ? "TERKUNCI" : "TERBUKA",
                      style: TextStyle(
                        color: locked ? Colors.red : Colors.green,
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
  // CARD STATUS KIPAS
  // =====================================================================
  Widget fanStatusCard(
  AnimationController fan1Ctrl,
  AnimationController fan2Ctrl,
) {
  return Card(
    color: const Color(0xff1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Kipas",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // ========================
          // KIPAS 1
          // ========================
          Row(
            children: [
              RotationTransition(
                turns: fan1On
                    ? Tween<double>(begin: 0, end: 1).animate(fan1Ctrl)
                    : const AlwaysStoppedAnimation(0),
                child: SvgPicture.asset(
                  "assets/images/propeller-icon.svg",
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    fan1On ? Colors.green : Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fan1On ? "Kipas 1: ON" : "Kipas 1: OFF",
                  style: TextStyle(
                    color: fan1On ? Colors.green : Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========================
          // KIPAS 2
          // ========================
          Row(
            children: [
              RotationTransition(
                turns: fan2On
                    ? Tween<double>(begin: 0, end: 1).animate(fan2Ctrl)
                    : const AlwaysStoppedAnimation(0),
                child: SvgPicture.asset(
                  "assets/images/propeller-icon.svg", 
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    fan2On ? Colors.green : Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fan2On ? "Kipas 2: ON" : "Kipas 2: OFF",
                  style: TextStyle(
                    color: fan2On ? Colors.green : Colors.red,
                    fontSize: 18,
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
          "Smart Home",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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

              // STATUS GAS
              gasStatusCard(),
              const SizedBox(height: 14),

              // STATUS PINTU
              doorStatusCard(),
              const SizedBox(height: 14),

              // STATUS KIPAS
              fanStatusCard(fan1Ctrl, fan2Ctrl),
              const SizedBox(height: 20),

              // Tombol Tambahkan User
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddUserPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tambahkan User",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol List User
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ListUserPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "List User Terdaftar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
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
