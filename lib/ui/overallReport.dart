import "package:flutter/material.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class OverallReport extends StatefulWidget {
  const OverallReport({Key? key}) : super(key: key);

  @override
  State<OverallReport> createState() => _OverallReportState();
}

class _OverallReportState extends State<OverallReport> {
  Map<String, int> chartData = {'Positive': 0, 'Neutral': 0, 'Negative': 0};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        "https://us-central1-sensorsprok.cloudfunctions.net/api/api/overall-satisfaction/"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        chartData = {
          'Positive': data['positiveCustomers'],
          'Neutral': data['neutralCustomers'],
          'Negative': data['negativeCustomers']
        };
      });
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
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "The Following Graph gives the number of Customers categorised based on their Satisfaction",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <ChartSeries<dynamic, String>>[
                    BarSeries<dynamic, String>(
                        dataSource: chartData.entries.toList(),
                        xValueMapper: (entry, _) => entry.key,
                        yValueMapper: (entry, _) => entry.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelAlignment: ChartDataLabelAlignment.middle,
                        ))
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
