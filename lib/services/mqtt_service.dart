import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';

class MQTTService {
  MqttServerClient? client;

  Function(SensorData)? onDataReceived; // callback ke UI
  Function(bool)? onConnectionChanged;  // ⬅️ Tambahan baru

  Future<void> connect() async {
    client = MqttServerClient.withPort(
        "9cce1c3452784c1aa895af074208531e.s1.eu.hivemq.cloud",
        "flutter_client",
        8883);

    client!.secure = true;

    // Load CA certificate
    SecurityContext ctx = SecurityContext.defaultContext;
    final ca = await rootBundle.load("assets/certs/isrgrootx1.pem");
    ctx.setTrustedCertificatesBytes(ca.buffer.asUint8List());

    client!.securityContext = ctx;

    final conn = MqttConnectMessage().startClean();
    client!.connectionMessage = conn;

    // ⬅️ Notifikasi ketika MQTT terhubung
    client!.onConnected = () {
      if (onConnectionChanged != null) onConnectionChanged!(true);
      print("MQTT Connected (callback)");
    };

    // ⬅️ Notifikasi ketika MQTT terputus
    client!.onDisconnected = () {
      if (onConnectionChanged != null) onConnectionChanged!(false);
      print("MQTT Disconnected");
    };

    try {
      await client!.connect("admin", "Admin123");
    } catch (e) {
      print("❌ MQTT error: $e");

      // ⬅️ Jika gagal connect, kirim status OFFLINE
      if (onConnectionChanged != null) onConnectionChanged!(false);
      return;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print("MQTT Connected with TLS");

      client!.subscribe("/smarthome/sensor/data", MqttQos.atMostOnce);

      client!.updates!.listen((event) {
        final rec = event[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(rec.payload.message);

        final data = SensorData.fromJson(json.decode(payload));

        if (onDataReceived != null) {
          onDataReceived!(data);
        }
      });
    }
  }
}
