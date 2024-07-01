import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class OverallReport extends StatefulWidget {
  const OverallReport({Key? key}) : super(key: key);

  @override
  State<OverallReport> createState() => _OverallReportState();
}

class _OverallReportState extends State<OverallReport> {
  List<ChartData> weightedEmotionData = [];
  List<ChartData> filteredData = [];
  double overallSentimentScore = 0.0;
  DateTime? startDate;
  DateTime? endDate;
  String? storeId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final box = await Hive.openBox('login');
    setState(() {
      storeId = box.get('storeId');
    });

    try {
      final response = await http.get(Uri.parse(
          "https://us-central1-sensorsprok.cloudfunctions.net/api/api/overall/$storeId"));
      print(storeId);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weightedEmotionData = (data['data'] as List)
              .map((item) => ChartData(
                    date: item['date'],
                    weightedEmotionPercents: Map<String, double>.from(
                        item['weightedEmotionPercents']),
                  ))
              .toList();
          filteredData = List.from(weightedEmotionData);
          overallSentimentScore = double.parse(data['overallSentimentScore']);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void filterDataByDateRange() {
    if (startDate != null && endDate != null) {
      setState(() {
        filteredData = weightedEmotionData.where((data) {
          DateTime dataDate = DateTime.parse(data.date);
          return dataDate.isAfter(startDate!) && dataDate.isBefore(endDate!);
        }).toList();
      });
    } else {
      setState(() {
        filteredData = List.from(weightedEmotionData);
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked.start != startDate && picked.end != endDate) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      filterDataByDateRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Text("Overall Report"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: const Text("Select Date Range"),
              ),
              const Text(
                "Weighted Emotion Percentages Over Time",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    intervalType:
                        DateTimeIntervalType.days, // Set interval type to days
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  series: <ChartSeries>[
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Happy'] ?? 0,
                      name: 'Happy',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Neutral'] ?? 0,
                      name: 'Neutral',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Surprised'] ?? 0,
                      name: 'Surprised',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Fearful'] ?? 0,
                      name: 'Fearful',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Angry'] ?? 0,
                      name: 'Angry',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Sad'] ?? 0,
                      name: 'Sad',
                    ),
                    LineSeries<ChartData, DateTime>(
                      dataSource: filteredData,
                      xValueMapper: (ChartData data, _) =>
                          DateTime.parse(data.date),
                      yValueMapper: (ChartData data, _) =>
                          data.weightedEmotionPercents['Disgusted'] ?? 0,
                      name: 'Disgusted',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "Overall Sentiment Score",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: -100,
                      maximum: 100,
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: -100,
                          endValue: 0,
                          color: Colors.red,
                        ),
                        GaugeRange(
                          startValue: 0,
                          endValue: 100,
                          color: Colors.green,
                        ),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(value: overallSentimentScore),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            overallSentimentScore.toString(),
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String date;
  final Map<String, double> weightedEmotionPercents;

  ChartData({required this.date, required this.weightedEmotionPercents});
}
