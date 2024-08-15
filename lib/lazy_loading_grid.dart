import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weather_summary.dart';

class LazyLoadingGrid extends StatefulWidget {
  const LazyLoadingGrid({super.key});

  @override
  State<LazyLoadingGrid> createState() => _LazyLoadingGridState();
}

class _LazyLoadingGridState extends State<LazyLoadingGrid> {
  final List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;
  final List<String> _cities = ['Qena']; // Static list of cities

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });
    print("Fetching Data");

    try {
      final List<Map<String, dynamic>> detailedItems = await Future.wait(_cities.map((city) async {
        try {
          final weatherResponse = await http.get(Uri.parse(
              "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=979e237b0f5e09e3c71616ac4781af58&units=metric"));
          if (weatherResponse.statusCode == 200) {
            final weatherData = json.decode(weatherResponse.body);

            return {
              'city': city,
              'description': weatherData['weather'][0]['description'] ?? 'N/A',
              'humidity': weatherData['main']['humidity'] ?? 0,
              'feelsLike': weatherData['main']['feels_like'] ?? 0.0,
              'visibility': weatherData['visibility'] ?? 0,
              'windSpeed': weatherData['wind']['speed'] ?? 0.0,
              'sunrise': weatherData['sys']['sunrise'] ?? 0,
              'sunset': weatherData['sys']['sunset'] ?? 0,
            };
          } else {
            print('Failed to get weather data for $city');
            return {
              'city': city,
              'description': 'N/A',
              'humidity': 0,
              'feelsLike': 0.0,
              'visibility': 0,
              'windSpeed': 0.0,
              'sunrise': 0,
              'sunset': 0,
            };
          }
        } catch (e) {
          print('Failed to get weather data for $city: $e');
          return {
            'city': city,
            'description': 'N/A',
            'humidity': 0,
            'feelsLike': 0.0,
            'visibility': 0,
            'windSpeed': 0.0,
            'sunrise': 0,
            'sunset': 0,
          };
        }
      }).toList());

      setState(() {
        _items.addAll(detailedItems);
        _isLoading = false;
      });
    } catch (e) {
      print('Error occurred while fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search City',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const WeatherSummary(),
        const SizedBox(height: 10),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isLoading &&
                  scrollInfo.metrics.pixels +
                          scrollInfo.metrics.viewportDimension >=
                      scrollInfo.metrics.maxScrollExtent - 5) {
                _loadMore();
                return true;
              } else {
                return false;
              }
            },
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive grid
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 1, // Adjust aspect ratio
              ),
              padding: const EdgeInsets.all(12.0),
              itemCount: 6,
              itemBuilder: (context, index) {
                final item = _items[index ~/ 6];
                switch (index % 6) {
                  case 0:
                    return WeatherDetailCard(
                      image: "assets/feellike 3.png",
                      title: 'Feels Like',
                      value: '${item['feelsLike']} °C',
                    );
                  case 1:
                    return WeatherDetailCard(
                      image: "assets/humidity 3.png",
                      title: 'Humidity',
                      value: '${item['humidity']}%',
                    );
                  case 2:
                    return WeatherDetailCard(
                      image: "assets/visibility 3.png",
                      title: 'Visibility',
                      value: '${item['visibility']} m',
                    );
                  case 3:
                    return WeatherDetailCard(
                      image: "assets/windspeed 3.png",
                      title: 'Wind Speed',
                      value: '${item['windSpeed']} m/s',
                    );
                  case 4:
                    return WeatherDetailCard(
                      image: "assets/sunrise 3.png",
                      title: 'Sunrise',
                      value: '${_formatTime(item['sunrise'])}',
                    );
                  case 5:
                    return WeatherDetailCard(
                      image: "assets/sunset 3.png",
                      title: 'Sunset',
                      value: '${_formatTime(item['sunset'])}',
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class WeatherDetailCard extends StatelessWidget {
  final String image;
  final String title;
  final String value;

  const WeatherDetailCard({
    required this.title,
    required this.value,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF22699D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, scale: 1),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
