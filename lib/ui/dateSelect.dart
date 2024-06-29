import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'login.dart';

class DateSelector extends StatefulWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final Box _boxLogin = Hive.box("login");

  final String _pickedInitialDateKey = "pickedInitialDate";
  final String _pickedFinalDateKey = "pickedFinalDate";

  String displayInitialDate = "No date selected";
  String displayFinalDate = "No date selected";

  String FormattedStart = "no date";
  String FormattedEnd = "not date";

  Future<void> _pickInitialDate(BuildContext context) async {
    final DateTime? Ipicked = await showDatePicker(
      context: context,
      initialDate: _boxLogin.get(_pickedInitialDateKey) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (Ipicked != null) {
      setState(() {
        _boxLogin.put(_pickedInitialDateKey, Ipicked);
        displayInitialDate = _formatDate(_boxLogin.get(_pickedInitialDateKey));
      });
    }
  }

  Future<void> _pickFinalDate(BuildContext context) async {
    final DateTime? Fpicked = await showDatePicker(
      context: context,
      initialDate: _boxLogin.get(_pickedFinalDateKey) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (Fpicked != null) {
      setState(() {
        _boxLogin.put(_pickedFinalDateKey, Fpicked);
        displayFinalDate = _formatDate(_boxLogin.get(_pickedFinalDateKey));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Satisfaction Statistics"),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(
                onPressed: () {
                  _boxLogin.clear();
                  _boxLogin.put("loginStatus", false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _pickInitialDate(context);
                      displayInitialDate =
                          _formatDate(_boxLogin.get(_pickedInitialDateKey));
                    });
                  },
                  child: const Text("Initial Date"),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _pickFinalDate(context);
                      displayFinalDate =
                          _formatDate(_boxLogin.get(_pickedFinalDateKey));
                    });
                  },
                  child: const Text("End Date"),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayInitialDate,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  displayFinalDate,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Text('100% Stacked Column Chart'),
                  _buildStackedColumnChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return "000-00-00";
    }

    return "${date.year}-${date.month.toString()}-${date.day.toString()}";
  }

  String formatDate(String dateStr) {
    // Split the date string into its components
    List<String> dateComponents = dateStr.split('-');

    if (dateComponents.length == 3) {
      // Ensure the month and day have two digits
      String year = dateComponents[0];
      String month =
          dateComponents[1].padLeft(2, '0'); // Add leading zero if needed
      String day =
          dateComponents[2].padLeft(2, '0'); // Add leading zero if needed

      // Construct the formatted date string
      return '$year-$month-$day';
    } else {
      // Handle invalid date strings
      return dateStr; // Return the original string or handle the error as needed
    }
  }

  Widget _buildStackedColumnChart() {
    return FutureBuilder<Map<String, Map<String, double>>>(
      future: fetchDataFromAPI(
        _formatDate(_boxLogin.get(_pickedInitialDateKey)),
        _formatDate(_boxLogin.get(_pickedFinalDateKey)),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return Text('No data available');
          }

          final List<String> dateLabels = data.keys.toList();
          final List<Map<String, double>> seriesData = data.values.toList();

          // Collect all unique emotions
          final Set<String> allEmotions = {};
          for (var emotionData in seriesData) {
            allEmotions.addAll(emotionData.keys);
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SfCartesianChart(
              title: ChartTitle(text: 'Emotion Percentages Over Time'),
              primaryXAxis: CategoryAxis(
                title: AxisTitle(text: 'Date'),
                labelRotation: -45,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Percentage'),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
              ),
              series: allEmotions.map((emotion) {
                return StackedColumn100Series<Map<String, double>, String>(
                  dataSource: seriesData,
                  xValueMapper: (datum, _) =>
                      dateLabels[seriesData.indexOf(datum)],
                  yValueMapper: (datum, _) => datum[emotion] ?? 0.0,
                  name: emotion,
                );
              }).toList(),
            ),
          );
        } else {
          return Text('No data available');
        }
      },
    );
  }

  Future<Map<String, Map<String, double>>> fetchDataFromAPI(
      String startDate, String endDate) async {
    String formattedStartDate = formatDate(startDate);
    String formattedEndDate = formatDate(endDate);

    final box = await Hive.openBox('login');

    String? storeId = box.get('storeId');

    print(
        'sending request https://us-central1-sensorsprok.cloudfunctions.net/api/api/date-range/$storeId/$formattedStartDate/$formattedEndDate \n');
    final response = await http.get(Uri.parse(
        "https://us-central1-sensorsprok.cloudfunctions.net/api/api/date-range/$storeId/$formattedStartDate/$formattedEndDate")); // Replace with your API endpoint

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Map<String, Map<String, double>> weightedEmotionPercents = {};

      responseData['weightedEmotionPercents'].forEach((date, emotions) {
        final Map<String, double> emotionPercentMap = {};
        emotions.forEach((emotion, percent) {
          emotionPercentMap[emotion] = double.parse(percent.toString());
        });
        weightedEmotionPercents[date] = emotionPercentMap;
      });

      return weightedEmotionPercents;
    } else {
      throw Exception('Failed to load data');
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// import 'login.dart';

// class DateSelector extends StatefulWidget {
//   const DateSelector({super.key});

//   @override
//   State<DateSelector> createState() => _HomeState();
// }

// class _HomeState extends State<DateSelector> {
//   final Box _boxLogin = Hive.box("login");

//   final String _pickedInitialDateKey = "pickedInitialDate";
//   final String _pickedFinalDateKey = "pickedFinalDate";

//   String displayInitialDate = "No date selected";
//   String displayFinalDate = "No date selected";

//   Future<void> _pickInitialDate(BuildContext context) async {
//     final DateTime? Ipicked = await showDatePicker(
//       context: context,
//       initialDate: _boxLogin.get(_pickedInitialDateKey) ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (Ipicked != null) {
//       setState(() {
//         _boxLogin.put(_pickedInitialDateKey, Ipicked);
//         displayInitialDate = _formatDate(_boxLogin.get(_pickedInitialDateKey));
//       });
//     }
//   }

//   Future<void> _pickFinalDate(BuildContext context) async {
//     final DateTime? Fpicked = await showDatePicker(
//       context: context,
//       initialDate: _boxLogin.get(_pickedFinalDateKey) ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (Fpicked != null) {
//       setState(() {
//         _boxLogin.put(_pickedFinalDateKey, Fpicked);
//         displayFinalDate = _formatDate(_boxLogin.get(_pickedFinalDateKey));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Customer Satisfaction Statistics"),
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DecoratedBox(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white),
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   _boxLogin.clear();
//                   _boxLogin.put("loginStatus", false);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return Login();
//                       },
//                     ),
//                   );
//                 },
//                 icon: const Icon(Icons.logout_rounded),
//               ),
//             ),
//           )
//         ],
//       ),
//       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _pickInitialDate(context);
//                       displayInitialDate =
//                           _formatDate(_boxLogin.get(_pickedInitialDateKey));
//                     });
//                   },
//                   child: const Text("Initial Date"),
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _pickFinalDate(context);
//                       displayFinalDate =
//                           _formatDate(_boxLogin.get(_pickedFinalDateKey));
//                     });
//                   },
//                   child: const Text("End Date"),
//                 )
//               ],
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   displayInitialDate,
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Text(
//                   displayFinalDate,
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) {
//       return "000-00-00";
//     }

//     return "${date.year}-${date.month.toString()}-${date.day.toString()}";
//   }
// }
