import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class WeeklySalesChart extends StatelessWidget {
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
              TTexts.weeklySalesTrade,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              height: 250,
              child: AnimatedLineChart(),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedLineChart extends StatefulWidget {
  @override
  _AnimatedLineChartState createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart> {
  List<SalesData> weeklySales = [
    SalesData("Mon", 12),
    SalesData("Tue", 24),
    SalesData("Wed", 17),
    SalesData("Thu", 37),
    SalesData("Fri", 40),
    SalesData("Sat", 38),
    SalesData("Sun", 49),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      mainData(),
      duration: const Duration(milliseconds: 1000), // Smooth animation
      curve: Curves.easeInOut, // Best for smooth animation
    );
  }

  LineChartData mainData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: weeklySales
              .asMap()
              .entries
              .map((entry) =>
              FlSpot(entry.key.toDouble(), entry.value.sales.toDouble()))
              .toList(),
          isCurved: true,
          color: TColors.primary,
          barWidth: 4,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [TColors.primary.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(show: true),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30, // Increase reserved space for better visibility

            getTitlesWidget: (value, _) {
              if (value >= 0 && value < weeklySales.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(weeklySales[value.toInt()].day),
                );
              }
              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                "${spot.y.toInt()} sales",
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}

class SalesData {
  final String day;
  final int sales;

  SalesData(this.day, this.sales);
}
