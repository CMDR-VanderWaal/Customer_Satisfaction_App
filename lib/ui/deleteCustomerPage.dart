import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class DeleteCustomerPage extends StatefulWidget {
  const DeleteCustomerPage({Key? key}) : super(key: key);

  @override
  _DeleteCustomerPageState createState() => _DeleteCustomerPageState();
}

class _DeleteCustomerPageState extends State<DeleteCustomerPage> {
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
    final box = await Hive.openBox('login');
    String? storeId = box.get('storeId');

    try {
      final response = await http.get(Uri.parse(
          'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customers/$storeId/list'));

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

  Future<void> deleteCustomer(String customerId) async {
    final box = await Hive.openBox('login');

    String? storeId = box.get('storeId');

    try {
      final response = await http.delete(Uri.parse(
          'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customers/$storeId/specific/$customerId'));

      if (response.statusCode == 200) {
        setState(() {
          customers
              .removeWhere((customer) => customer['customerId'] == customerId);
          filteredCustomers
              .removeWhere((customer) => customer['customerId'] == customerId);
        });
      } else {
        throw Exception(
            'Failed to delete customer. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting customer: $e');
      throw Exception('Failed to delete customer: $e');
    }
  }

  void _showDeleteDialog(String customerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this customer?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await deleteCustomer(customerId);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
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
        title: const Text("Delete Customers"),
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
                        DataColumn(label: Text('Actions')),
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
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                _showDeleteDialog(
                                    customer['customerId'] ?? 'UnknownID');
                              },
                              child: const Icon(
                                Icons.delete,
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
