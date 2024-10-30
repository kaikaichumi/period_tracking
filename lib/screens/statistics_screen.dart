// lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../models/period_record.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PeriodRecord> _records = [];
  bool _isLoading = true;
  
  // 統計數據
  double _averageCycleLength = 0;
  double _averagePeriodLength = 0;
  Map<String, int> _symptomFrequency = {};
  List<FlSpot> _cycleLengthSpots = [];
  List<FlSpot> _painLevelSpots = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 載入所有記錄
      final records = await DatabaseService.instance.getAllPeriods();
      records.sort((a, b) => a.startDate.compareTo(b.startDate));
      
      // 計算週期長度
      List<int> cycleLengths = [];
      for (int i = 0; i < records.length - 1; i++) {
        final difference = records[i + 1].startDate.difference(records[i].startDate).inDays;
        if (difference > 0 && difference < 45) { // 排除異常值
          cycleLengths.add(difference);
        }
      }
      
      // 計算經期長度
      List<int> periodLengths = [];
      for (var record in records) {
        if (record.endDate != null) {
          final length = record.endDate!.difference(record.startDate).inDays + 1;
          if (length > 0 && length < 15) { // 排除異常值
            periodLengths.add(length);
          }
        }
      }
      
      // 統計症狀頻率
      Map<String, int> symptomCounts = {};
      for (var record in records) {
        record.symptoms.forEach((symptom, hasSymptom) {
          if (hasSymptom) {
            symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
          }
        });
      }
      
      // 生成圖表數據
      List<FlSpot> cycleSpots = [];
      for (int i = 0; i < cycleLengths.length; i++) {
        cycleSpots.add(FlSpot(i.toDouble(), cycleLengths[i].toDouble()));
      }
      
      List<FlSpot> painSpots = [];
      for (int i = 0; i < records.length; i++) {
        painSpots.add(FlSpot(i.toDouble(), records[i].painLevel.toDouble()));
      }

      setState(() {
        _records = records;
        _averageCycleLength = cycleLengths.isEmpty 
            ? 0 
            : cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
        _averagePeriodLength = periodLengths.isEmpty 
            ? 0 
            : periodLengths.reduce((a, b) => a + b) / periodLengths.length;
        _symptomFrequency = symptomCounts;
        _cycleLengthSpots = cycleSpots;
        _painLevelSpots = painSpots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入數據時發生錯誤：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('統計分析'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '週期分析'),
            Tab(text: '症狀統計'),
            Tab(text: '趨勢圖表'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCycleAnalysis(),
                _buildSymptomStatistics(),
                _buildTrendCharts(),
              ],
            ),
    );
  }

  Widget _buildCycleAnalysis() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            title: '平均週期長度',
            value: '${_averageCycleLength.toStringAsFixed(1)}天',
            icon: Icons.calendar_today,
          ),
          SizedBox(height: 16),
          _buildStatCard(
            title: '平均經期長度',
            value: '${_averagePeriodLength.toStringAsFixed(1)}天',
            icon: Icons.hourglass_empty,
          ),
          SizedBox(height: 16),
          _buildStatCard(
            title: '記錄總數',
            value: '${_records.length}次',
            icon: Icons.history,
          ),
          SizedBox(height: 24),
          Text(
            '最近記錄',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          _buildRecentRecordsList(),
        ],
      ),
    );
  }

  Widget _buildSymptomStatistics() {
    final sortedSymptoms = _symptomFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '症狀出現頻率',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          ...sortedSymptoms.map((entry) => Column(
            children: [
              LinearProgressIndicator(
                value: entry.value / _records.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[300]!),
              ),
              ListTile(
                title: Text(entry.key),
                trailing: Text('${(entry.value / _records.length * 100).toStringAsFixed(1)}%'),
              ),
              SizedBox(height: 8),
            ],
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTrendCharts() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '週期長度趨勢',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _cycleLengthSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            '經痛程度趨勢',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _painLevelSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.pink[300]),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.pink[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecordsList() {
    final recentRecords = _records.reversed.take(5).toList();
    
    return Column(
      children: recentRecords.map((record) {
        final dateFormat = DateFormat('yyyy/MM/dd');
        return Card(
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.pink[300]),
            title: Text(dateFormat.format(record.startDate)),
            subtitle: Text(
              '持續時間：${record.endDate != null ? record.endDate!.difference(record.startDate).inDays + 1 : "未結束"} 天\n'
              '經痛程度：${record.painLevel}/10',
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}