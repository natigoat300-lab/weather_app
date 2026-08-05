import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] ?? {};
    return WeatherData(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 29.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 64,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 11.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 61,
    );
  }
}

class HourlyItem {
  final String time;
  final int temp;
  final int weatherCode;

  HourlyItem({
    required this.time,
    required this.temp,
    required this.weatherCode,
  });
}

class WeatherService {
  static const String _baseUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m';

  Future<WeatherData> fetchLiveWeather() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw Exception('Failed to load weather data from Open-Meteo API');
    }
  }

  List<HourlyItem> getPlaceholderHourlyForecast(double currentTemp) {
    final int baseTemp = currentTemp.round();
    return [
      HourlyItem(time: 'Now', temp: baseTemp, weatherCode: 61),
      HourlyItem(time: '5pm', temp: baseTemp - 1, weatherCode: 61),
      HourlyItem(time: '6pm', temp: baseTemp - 1, weatherCode: 63),
      HourlyItem(time: '7pm', temp: baseTemp - 2, weatherCode: 2),
      HourlyItem(time: '8pm', temp: baseTemp - 3, weatherCode: 0),
      HourlyItem(time: '9pm', temp: baseTemp - 4, weatherCode: 0),
    ];
  }
}
