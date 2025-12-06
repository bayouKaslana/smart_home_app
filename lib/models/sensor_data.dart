class SensorData {
  final double temperature;
  final double humidity;
  final int gas;   // ← gas berupa angka, bukan boolean
  final bool fan1;
  final bool fan2;
  final bool doorLocked;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.gas,
    required this.fan1,
    required this.fan2,
    required this.doorLocked,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json["temperature"] ?? 0.0).toDouble(),
      humidity: (json["humidity"] ?? 0.0).toDouble(),
      gas: json["gas"] ?? 0,   // ← MQ-6
      fan1: json['fan1'] == 1,
      fan2: json['fan2'] == 1,
      doorLocked: (json['door_locked'] ?? 1) == 1,  
    );
  }
}
