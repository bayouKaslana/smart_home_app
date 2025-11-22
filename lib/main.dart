import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mqtt_service.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        final mqtt = MQTTService();
        mqtt.connect();        // langsung connect MQTT saat app mulai
        return mqtt;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Home Monitoring',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DashboardPage(),
      ),
    );
  }
}
