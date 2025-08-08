import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Ventas del mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: _buildBarChart()),
            const SizedBox(height: 24),
            const Text('Distribución de libros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 200, child: _buildPieChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                return Text(months[value.toInt()]);
              },
              reservedSize: 32,
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < 6; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: (i + 1) * 20.0, color: Colors.blueAccent, width: 16),
            ]),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: 40, title: 'Vendidos', color: Colors.orangeAccent),
          PieChartSectionData(value: 30, title: 'Donados', color: Colors.green),
          PieChartSectionData(value: 30, title: 'Recientes', color: Colors.blueAccent),
        ],
      ),
    );
  }
}