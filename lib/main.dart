import 'package:flutter/material.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Addis Ababa Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1322),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  late Future<WeatherData> _weatherFuture;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshWeather();
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _weatherService.fetchLiveWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E283E),
              Color(0xFF111827),
              Color(0xFF090D16),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<WeatherData>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading weather data:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _refreshWeather,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final weather = snapshot.data!;
              final hourlyList =
                  _weatherService.getPlaceholderHourlyForecast(weather.temperature);

              return Column(
                children: [
                  // 1. Top Bar Navigation Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Menu Button
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.menu_rounded,
                              color: Colors.white70, size: 28),
                        ),
                        // Center Location Title
                        Column(
                          children: const [
                            Text(
                              'Addis Ababa, Ethiopia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Right Calendar / Action Button
                        IconButton(
                          onPressed: _refreshWeather,
                          icon: const Icon(Icons.calendar_month_outlined,
                              color: Colors.white70, size: 26),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Body Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // 2. Large Visual Weather Icon
                          Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.15),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.cloud,
                                  size: 130,
                                  color: Colors.grey.shade200,
                                ),
                                Positioned(
                                  bottom: 25,
                                  child: Row(
                                    children: [
                                      Icon(Icons.water_drop,
                                          size: 24, color: Colors.blue.shade400),
                                      Icon(Icons.water_drop,
                                          size: 28, color: Colors.blue.shade500),
                                      Icon(Icons.water_drop,
                                          size: 24, color: Colors.blue.shade400),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Temperature Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weather.temperature.round()}',
                                style: const TextStyle(
                                  fontSize: 84,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Expect high rain today.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 3. Live Metrics Row (Wind, Humidity, Sunshine)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161F33).withOpacity(0.7),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Wind
                                  _buildMetricItem(
                                    icon: Icons.air,
                                    value: '${weather.windSpeed.round()}km/hr',
                                  ),
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.white24,
                                  ),
                                  // Humidity
                                  _buildMetricItem(
                                    icon: Icons.water_drop_outlined,
                                    value:
                                        '${weather.humidity.toString().padLeft(2, '0')}%',
                                  ),
                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.white24,
                                  ),
                                  // Sun hours
                                  _buildMetricItem(
                                    icon: Icons.wb_sunny_outlined,
                                    value: '8hr',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 4. Hourly Forecast Section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const [
                                  Icon(Icons.access_time,
                                      size: 18, color: Colors.white70),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hourly Forecast',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Horizontal Hourly List
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              physics: const BouncingScrollPhysics(),
                              itemCount: hourlyList.length,
                              itemBuilder: (context, index) {
                                final item = hourlyList[index];
                                final isSelected = index == 0;

                                return Container(
                                  width: 90,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E2B45)
                                        : const Color(0xFF131B2C),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blueAccent.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.05),
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.2),
                                              blurRadius: 15,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.time,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white60,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.thunderstorm_outlined,
                                        color: Colors.blueLight,
                                        size: 28,
                                      ),
                                      Text(
                                        '${item.temp}°',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 5. Bottom Navigation Menu
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, bottom: 16.0, top: 8.0),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF151D2F),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, Icons.home_rounded),
                          _buildNavItem(1, Icons.search_rounded),
                          _buildNavItem(2, Icons.notifications_none_rounded),
                          _buildNavItem(3, Icons.map_outlined),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedNavIndex == index;
    return IconButton(
      onPressed: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white38,
        size: 26,
      ),
    );
  }
}
