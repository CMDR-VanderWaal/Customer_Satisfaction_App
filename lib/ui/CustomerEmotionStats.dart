import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class EmotionData {
  final String emotion;
  final double percent;

  EmotionData({
    required this.emotion,
    required this.percent,
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

  @override
  void initState() {
    super.initState();
    fetchEmotionPercents();
  }

  Future<void> fetchEmotionPercents() async {
    final response = await http.get(Uri.parse(
        'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customer-satisfaction-data/customer/${widget.customerName}'));
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> emotionData = json.decode(response.body);
      //final Map<String, double> rawEmotionPercents =
      //emotionData['emotionPercents'];
      final updatedEmotionPercents = <String, double>{};

      if (emotionData['emotionPercents'] != null) {
        final Map<String, dynamic> rawEmotionPercents =
            emotionData['emotionPercents'];
        rawEmotionPercents.forEach((key, value) {
          if (value is num) {
            updatedEmotionPercents[key] = value.toDouble();
          } else if (value is double) {
            updatedEmotionPercents[key] = value;
          }
        });
      }
      setState(() {
        emotionPercents = updatedEmotionPercents;
        print('Emotion Percents: $emotionPercents');
      });
    } else {
      throw Exception('Failed to load Emotion Data');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: Text('Emotion Statistics - ${widget.customerName}'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              'Emotion Statistics for ${widget.customerName} (ID : ${widget.customerId})'),
          const SizedBox(
            height: 20,
          ),
          SfCircularChart(
            series: _generatePieChartSeries(emotionPercents),
          )
        ],
      )),
    );
  }
}
