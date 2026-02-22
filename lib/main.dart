import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MaterialApp(home: AquaponicsDashboard(), debugShowCheckedModeBanner: false));

// --- MODELS ---

class LogEntry {
  final String message;
  final String timestamp;
  final Color color;
  final IconData icon;
  LogEntry({required this.message, required this.timestamp, required this.color, required this.icon});
}

class ChartPoint {
  final double time;
  final double value;
  ChartPoint(this.time, this.value);
}

// --- CONTROLLER / LOGIC ---

class AquaponicsController {
  double waterLevel = 72.0;
  double phLevel = 7.1;
  double temperature = 26.0;
  bool isPumpOn = false; // Added missing semicolon here
  
  List<LogEntry> logs = [];
  List<FlSpot> waterHistory = [];
  List<FlSpot> phHistory = [];
  
  String _lastPhStatus = "Optimal";
  String _lastTempStatus = "Stable";
  double _timeCounter = 0;

  Function? onUpdate;

  void init() {
    // Pre-fill some data for the graph
    for (int i = 0; i < 20; i++) {
      _timeCounter++;
      waterHistory.add(FlSpot(_timeCounter, 50 + Random().nextDouble() * 20));
      phHistory.add(FlSpot(_timeCounter, 6.5 + Random().nextDouble() * 1.0));
    }
  }

  void updateSimulation() {
    _timeCounter++;

    // 1. Water & Pump Logic
    if (isPumpOn) waterLevel += 5; else waterLevel -= 1.5;
    waterLevel = waterLevel.clamp(0, 100);

    if (waterLevel < 25 && !isPumpOn) {
      isPumpOn = true;
      _addLog("Water level low - Pump activated", Colors.orange, Icons.warning_amber_rounded);
    } else if (waterLevel > 70 && isPumpOn) {
      isPumpOn = false;
      _addLog("Target level reached - Pump OFF", Colors.green, Icons.check_circle);    }

    // 2. pH Logic
    phLevel = 6.2 + Random().nextDouble() * 1.8;
    String currentPhStatus = getPhStatus()['text'];
    if (currentPhStatus != _lastPhStatus) {
      _logStatusChange("pH", currentPhStatus, _lastPhStatus);
      _lastPhStatus = currentPhStatus;
    }

    // 3. Temperature Logic
    temperature = 18 + Random().nextDouble() * 15;
    String currentTempStatus = getTempStatus()['text'];
    if (currentTempStatus != _lastTempStatus) {
      _logStatusChange("Temperature", currentTempStatus, _lastTempStatus);
      _lastTempStatus = currentTempStatus;
    }

    // 4. Graph Data Management (Rolling 24 points)
    waterHistory.add(FlSpot(_timeCounter, waterLevel));
    phHistory.add(FlSpot(_timeCounter, phLevel * 10)); // Scaled for visibility on same axis
    if (waterHistory.length > 24) {
      waterHistory.removeAt(0);
      phHistory.removeAt(0);
    }
  }

  void _addLog(String message, Color color, IconData icon) {
    logs.insert(0, LogEntry(
      message: message,
      timestamp: DateFormat('HH:mm').format(DateTime.now()),
      color: color,
      icon: icon,
    ));
    if (logs.length > 15) logs.removeLast();  }

  void _logStatusChange(String type, String current, String last) {
    if (current == "Optimal" || current == "Stable") {
      _addLog("$type returned to safe range", Colors.green, Icons.check_circle);
    } else if (current == "Critical" || current == "Out of Range") {
      _addLog("ALERT: $type $current", Colors.red, Icons.error);
    }
  }

  Map<String, dynamic> getPhStatus() {
    if (phLevel >= 6.8 && phLevel <= 7.2) return {'text': 'Optimal', 'color': Colors.green};
    if (phLevel >= 6.5 && phLevel <= 7.5) return {'text': 'Balanced', 'color': Colors.orange};
    return {'text': 'Out of Range', 'color': Colors.red};
  }

  Map<String, dynamic> getTempStatus() {
    if (temperature >= 22 && temperature <= 28) return {'text': 'Stable', 'color': Colors.green};
    if (temperature >= 20 && temperature <= 30) return {'text': 'Warning', 'color': Colors.orange};
    return {'text': 'Critical', 'color': Colors.red};
  }
}

// --- UI SECTION ---

class AquaponicsDashboard extends StatefulWidget {
  @override
  _AquaponicsDashboardState createState() => _AquaponicsDashboardState();
}

class _AquaponicsDashboardState extends State<AquaponicsDashboard> {
  final AquaponicsController controller = AquaponicsController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller.init();
    _timer = Timer.periodic(Duration(seconds: 3), (t) => setState(() => controller.updateSimulation()));
  }

  @override
  Widget build(BuildContext context) {
    var ph = controller.getPhStatus();
    var temp = controller.getTempStatus();

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF1B5E20),
        title: Text("Smart Aquaponics Dashboard", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
            SizedBox(width: 5),
            Text("Connected  ", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Stats Row
            Row(
              children: [
                _buildStatCard("Water Level", "${controller.waterLevel.toInt()}%", "Normal", Colors.blue, Icons.water),
                SizedBox(width: 10),
                _buildStatCard("pH Level", controller.phLevel.toStringAsFixed(1), ph['text'], ph['color'], Icons.opacity),
                SizedBox(width: 10),
                _buildStatCard("Temperature", "${controller.temperature.toInt()}°C", temp['text'], temp['color'], Icons.thermostat),
              ],
            ),
            SizedBox(height: 16),
            
            // System Status
            _buildSectionHeader("System Status"),
            Container(
              padding: EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  Expanded(child: _buildToggleTile("Pump Status", controller.isPumpOn)),
                  Container(width: 1, height: 40, color: Colors.grey[200]),
                  Expanded(child: _buildPhAlertTile(ph['text'] == "Out of Range")),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Alerts & Logs
            _buildSectionHeader("Alerts & Logs"),
            Container(
              height: 180,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: _cardDecoration(),
              child: controller.logs.isEmpty 
                ? Center(child: Text("No recent activity"))
                : ListView.builder(
                    itemCount: controller.logs.length,
                    itemBuilder: (context, i) => _buildLogItem(controller.logs[i]),                  ),
            ),
            SizedBox(height: 16),

            // Sensor Graph
            _buildSectionHeader("Sensor Readings"),
            Container(
              height: 220,
              padding: EdgeInsets.fromLTRB(10, 20, 20, 10),
              decoration: _cardDecoration(),
              child: _buildGraph(),
            ),
          ],
        ),
      ),
    );  }

  Widget _buildStatCard(String label, String val, String status, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            SizedBox(height: 4),
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
              child: Text(status, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, bool val) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Auto Mode: ", style: TextStyle(fontSize: 11)),
            Switch(value: val, onChanged: null, activeColor: Colors.green),          ],
        )
      ],
    );
  }

  Widget _buildPhAlertTile(bool isAlert) {
    return Column(
      children: [
        Text("pH Alert", style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 8),        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isAlert ? Icons.error : Icons.check_circle, color: isAlert ? Colors.red : Colors.green, size: 18),
            SizedBox(width: 4),
            Text(isAlert ? "OUT OF RANGE" : "NORMAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.red : Colors.green)),
          ],
        )
      ],
    );
  }  Widget _buildLogItem(LogEntry log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(log.icon, color: log.color, size: 18),
          SizedBox(width: 12),
          Expanded(child: Text(log.message, style: TextStyle(fontSize: 12))),
          Text(log.timestamp, style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGraph() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: controller.waterHistory,
            isCurved: true,
            color: Colors.green,            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: controller.phHistory,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]))),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
  );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
