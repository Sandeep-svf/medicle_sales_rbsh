import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class WeatherService {
  // 🟢 FETCH FULL DASHBOARD DATA
  Future<Map<String, dynamic>?> getDailyWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final String todayDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Check Cache
    final String? lastFetchedStr = prefs.getString('last_weather_fetch_date');
    final String? cachedData = prefs.getString('cached_weather_data');

    if (lastFetchedStr == todayDateKey && cachedData != null) {
      return json.decode(cachedData);
    }

    // 2. Get Location & Fetch API
    Position? position = await _determinePosition();
    double lat = position?.latitude ?? 28.61;
    double lng = position?.longitude ?? 77.20;

    try {
      // 🟢 FIX: Added '&daily=temperature_2m_max,temperature_2m_min' to the URL
      final String url =
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code,apparent_temperature,relative_humidity_2m&hourly=temperature_2m,weather_code,apparent_temperature,precipitation_probability,wind_speed_10m,relative_humidity_2m&daily=temperature_2m_max,temperature_2m_min&timezone=auto";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await prefs.setString('cached_weather_data', response.body);
        await prefs.setString('last_weather_fetch_date', todayDateKey);
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  // 🟢 PARSE HOURLY DATA INTO ROBUST MODELS
  List<WeatherHour> getRichHourlyForecast(Map<String, dynamic> data) {
    if (data['hourly'] == null) return [];

    List<dynamic> times = data['hourly']['time'];
    List<dynamic> temps = data['hourly']['temperature_2m'];
    List<dynamic> codes = data['hourly']['weather_code'];
    List<dynamic> feelsLike = data['hourly']['apparent_temperature'];
    List<dynamic> rainChance = data['hourly']['precipitation_probability'];
    List<dynamic> wind = data['hourly']['wind_speed_10m'];
    List<dynamic> humidity = data['hourly']['relative_humidity_2m'];

    List<WeatherHour> filteredList = [];
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (int i = 0; i < times.length; i++) {
      String t = times[i];
      if (t.startsWith(todayStr)) {
        DateTime dt = DateTime.parse(t);
        // Show Standard Day: 6 AM to 10 PM
        if (dt.hour >= 6 && dt.hour <= 22) {
          filteredList.add(WeatherHour(
            time: DateFormat('h a').format(dt),
            rawTime: dt,
            temp: temps[i].round(),
            code: codes[i],
            feelsLike: feelsLike[i].round(),
            rainChance: rainChance[i].round(),
            windSpeed: wind[i].toDouble(),
            humidity: humidity[i].round(),
          ));
        }
      }
    }
    return filteredList;
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }
}

// 🟢 ROBUST DATA MODEL
class WeatherHour {
  final String time;
  final DateTime rawTime;
  final int temp;
  final int code;
  final int feelsLike;
  final int rainChance;
  final double windSpeed;
  final int humidity;

  WeatherHour({
    required this.time,
    required this.rawTime,
    required this.temp,
    required this.code,
    required this.feelsLike,
    required this.rainChance,
    required this.windSpeed,
    required this.humidity,
  });
}