import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<dynamic> customers = [];
  String? selectedCustomerId;
  List<dynamic> orders = [];
  bool isLoading = false;

  int? selectedProductId;
  int productQuantity = 1;
  double netTotal = 0.0;
  DateTime? selectedDate;
  int? editingProductIndex;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    selectedDate = DateTime.now();
  }

  Future<void> fetchCustomers() async {
    try {
      final response =
          await http.get(Uri.parse('https://localhost:7233/api/Customer'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          customers = data;
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      showErrorSnackBar('Error fetching customers: $e');
    }
  }

  Future<void> fetchOrders(String customerId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://localhost:7233/api/Order/bycustomer/${customerId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = data;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      showErrorSnackBar('Error fetching orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
        elevation: 8,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            Opacity(
              opacity: 0.2,
              child: Image.network(
                'https://png.pngtree.com/thumb_back/fh260/background/20240327/pngtree-supermarket-aisle-with-empty-shopping-cart-at-grocery-store-retail-business-image_15646095.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Background image failed to load',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Customer',
                      labelStyle: const TextStyle(color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color:Color.fromARGB(255, 2, 0, 16),),
                      ),
                    ),
                    value: selectedCustomerId,
                    items: customers.isNotEmpty
                        ? customers
                            .map<DropdownMenuItem<String>>((customer) =>
                                DropdownMenuItem(
                                  value: customer['id'].toString(),
                                  child: Text(customer['cust_Name']),
                                ))
                            .toList()
                        : [],
                    onChanged: (value) {
                      if (value != selectedCustomerId) {
                        setState(() {
                          selectedCustomerId = value;
                        });
                        if (value != null) {
                          fetchOrders(value);
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : orders.isEmpty
                          ? const Center(
                              child: Text(
                                'No orders found',
                                style: TextStyle(color: Colors.teal, fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  color: Colors.teal[50],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  child: ListTile(
                                    title: Text(
                                      'Order ID: ${order['orderId']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal[700]),
                                    ),
                                    subtitle: Text(
                                      'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(order['orderDate']))}',
                                      style: TextStyle(color: Colors.teal[600]),
                                    ),
                                    trailing: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total: \$${order['netTotal']}',
                                          style: TextStyle(
                                              color: Colors.teal[800],
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Price: \$${order['productPrice']}',
                                          style: TextStyle(color: Colors.teal[600]),
                                        ),
                                        Text(
                                          'Qty: ${order['productQuantity']}',
                                          style: TextStyle(color: Colors.teal[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
