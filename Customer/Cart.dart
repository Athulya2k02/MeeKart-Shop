import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final String apiUrlOrders = "https://localhost:7233/api/Order";
  final String apiUrlProducts = "https://localhost:7233/api/Product";

  List orders = [];
  List products = [];
  int? editingOrderId;
  List<Map<String, dynamic>> editingOrderProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
    fetchProducts();
  }

  Future<void> fetchOrderHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(apiUrlOrders));
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body) ?? [];
        });
      } else {
        showErrorSnackBar("Error fetching orders: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrlProducts));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body) ?? [];
        });
      } else {
        showErrorSnackBar("Error fetching products: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
    }
  }

  void startEditingOrder(int orderId, List<dynamic> orderProducts) {
    setState(() {
      editingOrderId = orderId;
      editingOrderProducts = orderProducts
          .map<Map<String, dynamic>>((product) => {
                "Prod_id": product["Prod_id"],
                "Name": product["Name"],
                "Qty": product["Qty"],
                "Price": product["Price"],
                "Total": product["Total"],
                "Stock": product["Stock"],
              })
          .toList();
    });
  }

  void updateProductQuantity(int index, int delta) {
    setState(() {
      final product = editingOrderProducts[index];
      int updatedQty = product["Qty"] + delta;

      if (updatedQty > 0 && updatedQty <= product["Stock"]) {
        editingOrderProducts[index]["Qty"] = updatedQty;
        editingOrderProducts[index]["Total"] =
            updatedQty * (product["Price"] ?? 0);
      } else {
        showErrorSnackBar("Invalid quantity. Check stock availability.");
      }
    });
  }

  Future<void> saveUpdatedOrder() async {
    if (editingOrderId == null) return;

    try {
      final response = await http.put(
        Uri.parse("$apiUrlOrders/$editingOrderId"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(editingOrderProducts),
      );

      if (response.statusCode == 200) {
        showSuccessSnackBar("Order updated successfully!");
        setState(() {
          editingOrderId = null;
          editingOrderProducts = [];
        });
        fetchOrderHistory(); // Refresh order history
      } else {
        showErrorSnackBar("Error updating order: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
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
        title: const Text("Order History", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 199, 192, 237),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
              child: editingOrderId == null
                  ? ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                                "Order ID: ${order["id"]} - Total: \$${order["Total"]}"),
                            subtitle: Text(
                                "Customer: ${order["Cust_name"]} - Date: ${order["Date"]}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => startEditingOrder(
                                  order["id"], order["OrderProducts"]),
                            ),
                          ),
                        );
                      },
                    )
                  : Column(
                      children: [
                        const Text(
                          "Edit Order",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                        child: ListView.builder(
                        itemCount: editingOrderProducts.length,
                        itemBuilder: (context, index) {
                        final product = editingOrderProducts[index];
                        return Card(
                        child: ListTile(
                        title: Text(product["Name"]),
                        subtitle: Text(
                       "Price: \$${product["Price"]}, Total: \$${product["Total"]}"),
                         trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                         children: [
                        IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                        updateProductQuantity(index, -1),
                         ),
                         Text("${product["Qty"]}"),
                         IconButton(
                         icon: const Icon(Icons.add),
                        onPressed: () =>
                        updateProductQuantity(index, 1),
                             ),
                            ],
                           ),
                          ),
                         );
                      },
                   ),
               ),
                        ElevatedButton(
                          onPressed: saveUpdatedOrder,
                          child: const Text("Save Changes"),
                        ),
                      ],
                    ),
            ),
    );
  }
}
