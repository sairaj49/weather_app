import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secretinfo.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  late String cityName = 'Goa';
  late TextEditingController cityNameController = TextEditingController();

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw 'Error:City not found. Setting to default(Goa) Please Refresh';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  ThemeData _currentTheme = ThemeData.dark(useMaterial3: true);
  void thememode() {
    if (_currentTheme == ThemeData.dark(useMaterial3: true)) {
      _currentTheme = ThemeData.light(useMaterial3: true);
    } else {
      _currentTheme = ThemeData.dark(useMaterial3: true);
    }
  }

  void search(String cityName) {
    setState(() {
      this.cityName = cityName;
      weather = getCurrentWeather(cityName);
    });
  }

  void refresh(String cityName) {
    setState(() {
      this.cityName = cityName;
      if (cityName.isEmpty) {
        setState(() {});
      } else {
        weather = getCurrentWeather(cityName);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather('Goa');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _currentTheme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                setState(() {
                  thememode();
                });
              },
              icon: const Icon(Icons.dark_mode_outlined)),
          title: const Text(
            'Weather APP',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                setState(() {});
                try {
                  await getCurrentWeather(cityName);
                } catch (e) {
                  // print('Error: City not found. Setting to default city (Goa)');
                  setState(() {
                    cityName = 'Goa';
                    weather = getCurrentWeather(cityName);
                  });
                }
              },
              icon: const Icon(
                Icons.refresh,
              ),
            )
          ],
        ),
        body: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            final data = snapshot.data!;

            final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'] - 273.15;

            final currentSky = currentWeatherData['weather'][0]['main'];

            final currentPressure = currentWeatherData['main']['pressure'];

            final windSpeed = currentWeatherData['wind']['speed'];

            final currentHumidity = currentWeatherData['main']['humidity'];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.black87),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(
                                top: 0, right: 30, bottom: 0, left: 0),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 21, 23, 24),
                            ),
                            prefixIconConstraints:
                                BoxConstraints(minHeight: 20, maxWidth: 30),
                            hintText: ' Search For City',
                            enabledBorder: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black),
                            border: InputBorder.none),
                        controller: cityNameController,
                        onSubmitted: (value) {
                          search(value);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    Center(
                      child: Text(
                        'Now Showing for $cityName',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    //main card
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        //merges with the background
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    '${currentTemp != 0 ? currentTemp.toStringAsFixed(2) : currentTemp.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Icon(
                                    currentSky == 'Clouds' ||
                                            currentSky == 'Rain'
                                        ? Icons.cloud
                                        : Icons.sunny,
                                    size: 70,
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    currentSky,
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final hourlyForecast = data['list'][index + 1];
                          final hourlySky =
                              data['list'][index + 1]['weather'][0]['main'];
                          final hourlyTemp =
                              hourlyForecast['main']['temp'].toString();
                          final time = DateTime.parse(hourlyForecast['dt_txt']);
                          return HourlyForecastItems(
                            cityName: cityName,
                            hour: DateFormat.j().format(time),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            temp: hourlyTemp,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //additional information
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInfoitem(
                          icon: Icons.water_drop,
                          label: 'Humidity',
                          value: currentHumidity.toString(),
                        ),
                        AdditionalInfoitem(
                          icon: Icons.air,
                          label: 'Wind Speed',
                          value: windSpeed.toString(),
                        ),
                        AdditionalInfoitem(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: currentPressure.toString(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
