import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchWeatherData(
    double latitude, double longitude) async {
  var apiUrl =
      "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m";

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Weather data fetch failed');
  }
}

Future<CityInfo> fetchCityInfo(String cityName) async {
  final url =
      'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=10&language=en&format=json';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> cityList = json.decode(response.body)['results'];
    if (cityList.isNotEmpty) {
      return CityInfo.fromJson(cityList[0]);
    } else {
      throw Exception('City not found');
    }
  } else {
    throw Exception('Failed to load city information');
  }
}

class WeatherData {
  final double latitude;
  final double longitude;
  final double temperature;
  final double windSpeed;
  final String time;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.windSpeed,
    required this.time,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      temperature: json['current']['temperature_2m'],
      windSpeed: json['current']['wind_speed_10m'],
      time: json['current']['time'],
    );
  }

  @override
  String toString() {
    return 'Latitude: $latitude\nLongitude: $longitude\nTemperature: $temperature\nWind Speed: $windSpeed\nTime: $time';
  }
}

class CityInfo {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String timezone;

  CityInfo({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.timezone,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      country: json['country'],
      timezone: json['timezone'],
    );
  }

  @override
  String toString() {
    return "$name, $country; $latitude, $longitude";
  }
}

void main() async {
  try {
    var cityInfo = await fetchCityInfo('Bishkek');
    var weatherData =
        await fetchWeatherData(cityInfo.latitude, cityInfo.longitude);
    var data = WeatherData.fromJson(weatherData);
    print(data);
  } catch (e) {
    print('Error fetching weather data: $e');
  }
}
