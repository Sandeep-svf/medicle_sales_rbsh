import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class SalesTargetChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.dailySaleTarget,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 10,),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChartWidget(),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  /// Legend showing "Pending" (Red) and "Completed" (Green)
  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.red, TTexts.pending),
        const SizedBox(width: 16),
        _legendItem(Colors.green, TTexts.completed),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<SalesData> salesData = [
    SalesData(TTexts.calls, total: 10, achieved: 7),
    SalesData(TTexts.visits, total: 10, achieved: 5),
    SalesData(TTexts.orders, total: 10, achieved: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10, // Set a slightly higher maxY for label spacing
        barGroups: salesData.map((data) => _generateBarGroup(data)).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() == 0) return _buildTitle(TTexts.calls);
                if (value.toInt() == 1) return _buildTitle(TTexts.visits);
                if (value.toInt() == 2) return _buildTitle(TTexts.orders);
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
      ),
    );
  }

  /// Generates a bar with two sections (Green for Achieved, Red for Remaining)
  BarChartGroupData _generateBarGroup(SalesData data) {
    double greenHeight = data.achieved.toDouble();
    double totalHeight = data.total.toDouble();
    int xIndex = salesData.indexOf(data);

    return BarChartGroupData(
      x: xIndex,
      barRods: [
        BarChartRodData(
          toY: totalHeight,
          rodStackItems: [
            BarChartRodStackItem(0, greenHeight, Colors.green), // Achieved
            BarChartRodStackItem(greenHeight, totalHeight, Colors.red), // Pending
          ],
          width: 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [1],
      barsSpace: 4,
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w400),
      ),
    );
  }
}

/// Model class for sales data
class SalesData {
  final String category;
  final int total;
  final int achieved;

  SalesData(this.category, {required this.total, required this.achieved});
}
