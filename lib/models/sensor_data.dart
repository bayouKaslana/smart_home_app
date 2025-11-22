class SensorData {
  final double temperature;
  final double humidity;
  final bool gasDetected;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.gasDetected,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json["temperature"] ?? 0.0).toDouble(),
      humidity: (json["humidity"] ?? 0.0).toDouble(),
      gasDetected: json["gasDetected"] ?? false, // ← FIX
    );
  }
}
