import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmotionData {
  final String emotion;
  final double percent;

  EmotionData({
    required this.emotion,
    required this.percent,
  });
}

class DatewiseEmotionData {
  final DateTime date;
  final Map<String, double> weightedEmotionPercents;

  DatewiseEmotionData({
    required this.date,
    required this.weightedEmotionPercents,
  });
}

class CustomerEmotionStats extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerEmotionStats({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<CustomerEmotionStats> createState() => _CustomerEmotionStatsState();
}

class _CustomerEmotionStatsState extends State<CustomerEmotionStats> {
  Map<String, double> emotionPercents = {};
  List<DatewiseEmotionData> datewiseData = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    fetchEmotionPercents();
  }

  Future<void> fetchEmotionPercents() async {
    final box = await Hive.openBox('login');
    String? storeId = box.get('storeId');

    final response = await http.get(Uri.parse(
        "https://us-central1-sensorsprok.cloudfunctions.net/api/api/customers/$storeId/specific/${widget.customerId}"));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Parse overall emotion percentages
      final Map<String, double> updatedEmotionPercents = {};
      if (responseData['emotionPercents'] != null) {
        final Map<String, dynamic> rawEmotionPercents =
            responseData['emotionPercents'];
        rawEmotionPercents.forEach((key, value) {
          if (value is num) {
            updatedEmotionPercents[key] = value.toDouble();
          } else if (value is double) {
            updatedEmotionPercents[key] = value;
          }
        });
      }

      // Parse datewise emotion percentages
      final List<DatewiseEmotionData> updatedDatewiseData = [];
      if (responseData['data'] != null) {
        final List<dynamic> rawData = responseData['data'];
        rawData.forEach((datewiseEntry) {
          final DateTime date = DateTime.parse(datewiseEntry['date']);
          final Map<String, double> weightedEmotionPercents = {};
          final Map<String, dynamic> rawWeightedPercents =
              datewiseEntry['weightedEmotionPercents'];
          rawWeightedPercents.forEach((key, value) {
            if (value is num) {
              weightedEmotionPercents[key] = value.toDouble();
            } else if (value is double) {
              weightedEmotionPercents[key] = value;
            }
          });
          updatedDatewiseData.add(
            DatewiseEmotionData(
                date: DateTime(date.year, date.month,
                    date.day), // Ensure time is set to 00:00:00
                weightedEmotionPercents: weightedEmotionPercents),
          );
        });
      }

      setState(() {
        emotionPercents = updatedEmotionPercents;
        datewiseData = fillMissingDates(updatedDatewiseData);
        print('Emotion Percents: $emotionPercents');
        print('Datewise Data: $datewiseData');
      });
    } else {
      throw Exception('Failed to load Emotion Data');
    }
  }

  List<DatewiseEmotionData> fillMissingDates(List<DatewiseEmotionData> data) {
    if (data.isEmpty) return data;
    List<DatewiseEmotionData> filledData = [];
    DateTime current = data.first.date;
    DateTime end = data.last.date;

    Map<DateTime, DatewiseEmotionData> dataMap = {
      for (var item in data) item.date: item
    };

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (dataMap.containsKey(current)) {
        filledData.add(dataMap[current]!);
      } else {
        filledData.add(DatewiseEmotionData(
          date: current,
          weightedEmotionPercents: {
            'Neutral': 0.0,
            'Fearful': 0.0,
            'Surprised': 0.0,
            'Happy': 0.0,
            'Angry': 0.0,
            'Sad': 0.0,
          },
        ));
      }
      current = current.add(Duration(days: 1));
    }

    return filledData;
  }

  List<PieSeries<EmotionData, String>> _generatePieChartSeries(
      Map<String, double> emotionPercents) {
    final List<EmotionData> data = emotionPercents.entries
        .map((entry) => EmotionData(emotion: entry.key, percent: entry.value))
        .toList();
    return <PieSeries<EmotionData, String>>[
      PieSeries<EmotionData, String>(
        dataSource: data,
        xValueMapper: (EmotionData emotionData, _) => emotionData.emotion,
        yValueMapper: (EmotionData emotionData, _) => emotionData.percent,
        dataLabelMapper: (EmotionData emotionData, _) {
          return '${emotionData.emotion}: ${emotionData.percent.toStringAsFixed(2)}%';
        },
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.inside,
          textStyle: TextStyle(fontSize: 12),
        ),
      ),
    ];
  }

  List<LineSeries<DatewiseEmotionData, DateTime>> _generateLineChartSeries(
      List<DatewiseEmotionData> datewiseData) {
    final List<String> emotions = [
      'Neutral',
      'Fearful',
      'Surprised',
      'Happy',
      'Angry',
      'Sad',
    ];

    // Add initial data point with all emotions set to 0
    final initialDate = datewiseData.isNotEmpty
        ? datewiseData.first.date.subtract(Duration(days: 1))
        : DateTime.now();

    final initialData = DatewiseEmotionData(
      date: DateTime(initialDate.year, initialDate.month,
          initialDate.day), // Ensure time is set to 00:00:00
      weightedEmotionPercents: {
        'Neutral': 0.0,
        'Fearful': 0.0,
        'Surprised': 0.0,
        'Happy': 0.0,
        'Angry': 0.0,
        'Sad': 0.0,
      },
    );

    final List<DatewiseEmotionData> modifiedDatewiseData = [
      initialData,
      ...datewiseData
    ];

    return emotions.map((emotion) {
      return LineSeries<DatewiseEmotionData, DateTime>(
        name: emotion,
        dataSource: modifiedDatewiseData,
        xValueMapper: (DatewiseEmotionData data, _) => data.date,
        yValueMapper: (DatewiseEmotionData data, _) =>
            data.weightedEmotionPercents[emotion] ?? 0,
        dataLabelSettings: DataLabelSettings(
          isVisible: false,
        ),
      );
    }).toList();
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
    }
  }

  List<DatewiseEmotionData> getFilteredDatewiseData() {
    if (startDate != null && endDate != null) {
      return datewiseData.where((data) {
        return data.date.isAfter(startDate!) && data.date.isBefore(endDate!);
      }).toList();
    } else {
      return datewiseData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text('Emotion Statistics - ${widget.customerName}'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'Emotion Statistics for ${widget.customerName} (ID: ${widget.customerId})'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () => _selectDateRange(context),
                child: const Text('Select Date Range'),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 300,
                padding: EdgeInsets.all(16),
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    title: AxisTitle(text: 'Date'),
                    intervalType:
                        DateTimeIntervalType.days, // Ensure date interval
                  ),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: 'Weighted Emotion Percents'),
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: _generateLineChartSeries(getFilteredDatewiseData()),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 300,
                padding: EdgeInsets.all(16),
                child: SfCircularChart(
                  legend: Legend(
                    isVisible: true, // Show legend
                    position: LegendPosition.bottom, // Position of the legend
                    overflowMode:
                        LegendItemOverflowMode.wrap, // Manage overflow
                  ),
                  series: _generatePieChartSeries(emotionPercents),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
