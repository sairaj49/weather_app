import 'package:flutter/material.dart';

class HourlyForecastItems extends StatelessWidget {
  final String hour;
  final IconData icon;
  final String temp;
  final String cityName;
  const HourlyForecastItems({
    super.key,
    required this.hour,
    required this.icon,
    required this.temp,
    required this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              hour,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              temp,
            ),
          ],
        ),
      ),
    );
  }
}
