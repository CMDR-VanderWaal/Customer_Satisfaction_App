import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'dart:convert';
import 'CustomerEmotionStats.dart';

class CustomerWise extends StatefulWidget {
  const CustomerWise({super.key});

  @override
  State<CustomerWise> createState() => _CustomerWiseState();
}

class _CustomerWiseState extends State<CustomerWise> {
  List<Map<String, dynamic>> customers = [];
  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final response = await http.get(Uri.parse(
        'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customer-satisfaction-data/customers/'));

    if (response.statusCode == 200) {
      final List<dynamic> customerList = json.decode(response.body);
      setState(() {
        customers = List<Map<String, dynamic>>.from(customerList);
      });
    } else {
      throw Exception('Failed to Load Customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Text("Customer Wise Report"),
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
      body: customers.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Customer ID')),
                        DataColumn(label: Text('Customer Name')),
                        DataColumn(label: Text('Report')),
                      ],
                      rows: customers.map((customer) {
                        return DataRow(
                          cells: [
                            DataCell(
                                Text(customer['customerId'] ?? 'Unknown ID')),
                            DataCell(Text(customer['customerName'] ??
                                'Unknown Customer')),
                            DataCell(ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              onPressed: () {
                                print('View Report');
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return CustomerEmotionStats(
                                      customerId:
                                          customer['customerId'] ?? 'UnknownID',
                                      customerName: customer['customerName'] ??
                                          'Unknown Name',
                                    );
                                  },
                                ));
                              },
                              child: const Icon(
                                Icons.search,
                                size: 15,
                              ),
                            ))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
