import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, centerTitle: true, title: const Text('BIOMETRIC DATA', style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeightCard(),
            const SizedBox(height: 32),
            const Text('VOLUME TREND', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildVolumeChart(),
            const SizedBox(height: 32),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CURRENT WEIGHT', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('84.5', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4),
                        child: Text('KG', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: AppTheme.limeAccent),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(value: 0.7, backgroundColor: Colors.white10, color: AppTheme.limeAccent, minHeight: 2),
        ],
      ),
    );
  }

  Widget _buildVolumeChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [const FlSpot(0, 3), const FlSpot(1, 2), const FlSpot(2, 5), const FlSpot(3, 3.5), const FlSpot(4, 4), const FlSpot(5, 3)],
              isCurved: true,
              color: AppTheme.limeAccent,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppTheme.limeAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT SESSIONS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => _buildHistoryItem()),
      ],
    );
  }

  Widget _buildHistoryItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Elite Push Protocol', style: TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              Text('MAY 09 • 45 MIN', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
            ],
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
