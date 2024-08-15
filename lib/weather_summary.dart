import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherSummary extends StatelessWidget {
  const WeatherSummary({super.key});

  Future<Map<String, dynamic>> _fetchWeather() async {
    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=qena&appid=979e237b0f5e09e3c71616ac4781af58&units=metric"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchWeather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final weather = snapshot.data!;
        final temperature = weather['main']['temp'];
        final weatherDescription = weather['weather'][0]['description'];
        final cityName = weather['name'];

        return Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.18),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Text(
                cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Image.asset("assets/Cloud 3.png", scale: 1.2, 
              height: 250,
              ),
              
              Text(
                '$temperature °C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weatherDescription,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
