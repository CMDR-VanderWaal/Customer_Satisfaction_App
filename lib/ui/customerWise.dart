import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CustomerEmotionStats.dart';

class CustomerWise extends StatefulWidget {
  const CustomerWise({super.key});

  @override
  State<CustomerWise> createState() => _CustomerWiseState();
}

class _CustomerWiseState extends State<CustomerWise> {
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse(
          'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customers/list'));

      if (response.statusCode == 200) {
        final List<dynamic> customerList = json.decode(response.body);
        setState(() {
          customers = List<Map<String, dynamic>>.from(customerList);
          filteredCustomers = customers;
        });
      } else {
        throw Exception(
            'Failed to load customers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customers: $e');
      throw Exception('Failed to load customers: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      filteredCustomers = customers.where((customer) {
        final customerId = customer['customerId']?.toLowerCase() ?? '';
        return customerId.contains(_searchQuery);
      }).toList();
    });
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Customer ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Customer ID')),
                        DataColumn(label: Text('Customer Name')),
                        DataColumn(label: Text('Report')),
                      ],
                      rows: filteredCustomers.map((customer) {
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
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
