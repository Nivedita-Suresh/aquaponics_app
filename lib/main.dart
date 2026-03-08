import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AquaponicsApp());
}

class AquaponicsApp extends StatelessWidget {
  const AquaponicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final String url = 'http://192.168.4.1';

  double distance = 0;
  double temperature = 0;
  double ph = 6.4;
  bool connected = false;
  String error = '';

  final List<double> distanceHistory = <double>[];
  final List<double> temperatureHistory = <double>[];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        _setDisconnected('HTTP ${response.statusCode}');
        return;
      }

      final body = response.body;
      final distMatch = RegExp(r'Distance:\s*(-?\d+)', caseSensitive: false)
          .firstMatch(body);
      final tempMatch =
          RegExp(r'Temperature:\s*(-?\d+(?:\.\d+)?)', caseSensitive: false)
              .firstMatch(body);

      if (distMatch == null || tempMatch == null) {
        _setDisconnected('Response format mismatch');
        return;
      }

      final distValue = double.parse(distMatch.group(1)!);
      final tempValue = double.parse(tempMatch.group(1)!);

      if (!mounted) return;
      setState(() {
        connected = true;
        error = '';
        distance = distValue;
        temperature = tempValue;

        distanceHistory.add(distValue);
        temperatureHistory.add(tempValue);

        if (distanceHistory.length > 20) {
          distanceHistory.removeAt(0);
        }
        if (temperatureHistory.length > 20) {
          temperatureHistory.removeAt(0);
        }
      });
    } catch (e) {
      _setDisconnected(e.toString());
    }
  }

  void _setDisconnected(String message) {
    if (!mounted) return;
    setState(() {
      connected = false;
      error = message;
    });
  }

  Widget buildSensorCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGraph(List<double> data, Color color) {
    if (data.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: List<FlSpot>.generate(
              data.length,
              (int i) => FlSpot(i.toDouble(), data[i]),
            ),
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Smart Aquaponics Dashboard'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 12,
                  color: connected ? Colors.greenAccent : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  connected ? 'Connected' : 'Disconnected',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                buildSensorCard(
                  'Water Level',
                  '${distance.toStringAsFixed(0)} cm',
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                buildSensorCard('pH Level', ph.toStringAsFixed(1), Colors.orange),
                const SizedBox(width: 10),
                buildSensorCard(
                  'Temperature',
                  '${temperature.toStringAsFixed(1)} C',
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Sensor Readings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Water Level History'),
            SizedBox(height: 150, child: buildGraph(distanceHistory, Colors.blue)),
            const SizedBox(height: 20),
            const Text('Temperature History'),
            SizedBox(
              height: 150,
              child: buildGraph(temperatureHistory, Colors.red),
            ),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
