import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double waterLevel = 72;
  double phLevel = 7.1;
  double temperature = 26;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    startMockData();
  }

  void startMockData() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        waterLevel = 60 + Random().nextInt(30).toDouble();
        phLevel = 6.5 + Random().nextDouble();
        temperature = 24 + Random().nextInt(5).toDouble();
        isConnected = Random().nextInt(10) > 1;
      });
    });
  }

  Widget infoCard(String title, String value, String status, Color color) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(status, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Smart Aquaponics Dashboard'),
      Row(
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: isConnected ? Colors.green : Colors.red,
          ),
          SizedBox(width: 6),
          Text(
            isConnected ? 'Connected' : 'Not Connected',
            style: TextStyle(fontSize: 14),
          ),
        ],
      )
    ],
  ),
),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                infoCard(
                  "Water Level",
                  "${waterLevel.toStringAsFixed(0)}%",
                  "Normal",
                  Colors.blue,
                ),
                infoCard(
                  "pH Level",
                  phLevel.toStringAsFixed(1),
                  "Optimal",
                  Colors.green,
                ),
                infoCard(
                  "Temperature",
                  "${temperature.toStringAsFixed(0)}°C",
                  "Stable",
                  Colors.red,
                ),
              ],
            ),
            SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("System Status",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Pump Status"),
                        Switch(
                          value: waterLevel < 65,
                          onChanged: (value) {},
                          activeThumbColor: Colors.green,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}