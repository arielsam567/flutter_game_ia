import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartPage extends StatefulWidget {
  final List<GenerationInfo> chartData;

  const LineChartPage({required this.chartData, super.key});

  @override
  LineChartPageState createState() => LineChartPageState();
}

class LineChartPageState extends State<LineChartPage> {
  @override
  void initState() {
    super.initState();
    if (widget.chartData.isNotEmpty) {
      widget.chartData.sort((a, b) => a.generation.compareTo(b.generation));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: NumericAxis(),
      series: <ChartSeries>[
        LineSeries<GenerationInfo, double>(
          dataSource: widget.chartData,
          xValueMapper: (info, _) => info.generation * 1.0,
          yValueMapper: (info, _) => info.distance,
        ),
      ],
    );
  }
}

class GenerationInfo {
  final int generation;
  final double distance;

  GenerationInfo(this.generation, this.distance);

  GenerationInfo.fromJson(Map<String, dynamic> json)
      : generation = json['generation'],
        distance = json['distance'];

  Map<String, dynamic> toJson() => {
        'generation': generation,
        'distance': distance,
      };
}
