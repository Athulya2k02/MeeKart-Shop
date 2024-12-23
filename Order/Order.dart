import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final String apiUrlCustomers = "https://localhost:7233/api/Customer";
  final String apiUrlProducts = "https://localhost:7233/api/Product";
  final String apiUrlOrders = "https://localhost:7233/api/Order";

  List customers = [];
  List products = [];
  List<Map<String, dynamic>> orderProducts = [];

  int? selectedCustomerId;
  int? selectedProductId;
  int productQuantity = 1;
  double netTotal = 0.0;
  DateTime? selectedDate;
  int? editingProductIndex; 

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    fetchProducts();
    selectedDate = DateTime.now();
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse(apiUrlCustomers));
      if (response.statusCode == 200) {
        setState(() {
          customers = json.decode(response.body) ?? [];
          if (customers.isNotEmpty) {
            selectedCustomerId = customers[0]["id"];
          }
        });
      } else {
        showErrorSnackBar("Error fetching customers: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrlProducts));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          products = decodedResponse ?? [];
          if (products.isNotEmpty) {
            selectedProductId = products[0]["prod_id"];
          }
        });
      } else {
        showErrorSnackBar("Error fetching products: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
    }
  }

  void addProductToOrder() {
    if (selectedDate == null) {
      showErrorSnackBar("Please select a date for the order.");
      return;
    }

    if (selectedProductId == null || selectedCustomerId == null) {
      showErrorSnackBar("Please select a product and customer.");
      return;
    }

    final selectedProduct = products.firstWhere(
      (product) => product["prod_id"] == selectedProductId,
      orElse: () => null,
    );

    if (selectedProduct == null) {
      showErrorSnackBar("Invalid product selected.");
      return;
    }

    if (productQuantity <= 0) {
      showErrorSnackBar("Quantity must be greater than 0.");
      return;
    }

    setState(() {
      orderProducts.add({
        "Prod_id": selectedProduct["prod_id"],
        "Cust_id": selectedCustomerId,
        "Date": selectedDate?.toIso8601String() ?? '',
        "Total": productQuantity * (selectedProduct['mrp'] ?? 0),
        "Qty": productQuantity,
        "Name": selectedProduct["prod_name"],
        "Price": selectedProduct["mrp"],
        "Stock": selectedProduct["stock"]
      });
    });

    showSuccessSnackBar("Product added to order!");
  }

  double calculateOrderTotal() {
    return orderProducts.fold(0.0, (sum, product) {
      return sum + product['Total'];
    });
  }

  Future<void> placeOrder() async {
    setState(() {
      netTotal = calculateOrderTotal();
    });

    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Order", style: TextStyle(color: Colors.teal)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order Summary:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 10),
              ...orderProducts.map((product) => ListTile(
                    title: Text(product["Name"], style: TextStyle(color: Colors.teal)),
                    subtitle: Text(
                        "Qty: ${product["Qty"]}, Price: \$${product["Price"]}, Total: \$${product["Total"]}",
                        style: TextStyle(color: Colors.grey)),
                  )),
              const SizedBox(height: 10),
              Text("Net Total: \$${netTotal.toStringAsFixed(2)}", style: TextStyle(color: Colors.green)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final List<Map<String, dynamic>> ordersToSend = orderProducts.map((orderProduct) {
        return {
          "Prod_id": orderProduct["Prod_id"],
          "Cust_id": orderProduct["Cust_id"],
          "quantity": orderProduct["Qty"],
          "Price": orderProduct["Price"],
          "Total": orderProduct["Total"],
          "date": orderProduct["Date"]
        };
      }).toList();

      final response = await http.post(
        Uri.parse(apiUrlOrders),
        headers: {"Content-Type": "application/json"},
        body: json.encode(ordersToSend),
      );

      if (response.statusCode != 200) {
        showErrorSnackBar("Error placing order: ${response.statusCode}");
        return;
      }

      await updateProductStock();

      showSuccessSnackBar("Order placed successfully!");

      setState(() {
        orderProducts.clear();
      });
    } catch (e) {
      showErrorSnackBar("Error: $e");
    }
  }

  Future<void> updateProductStock() async {
    try {
      for (var product in orderProducts) {
        final String apiUrlStockUpdate = "https://localhost:7233/api/Product/${product['Prod_id']}";

        final response = await http.put(
          Uri.parse(apiUrlStockUpdate),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "prod_name": product['Name'],
            "MRP": product['Price'],
            "Qty": product['Qty'],
            "Stock": product['Stock'] - product['Qty']
          }),
        );

        if (response.statusCode != 204) {
          showErrorSnackBar("Error updating stock for product ${product['Name']}: ${response.statusCode}");
          return;
        }
      }

      showSuccessSnackBar("Stock updated successfully for all products!");
    } catch (e) {
      showErrorSnackBar("Error updating stock: $e");
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

  Future<void> selectOrderDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  void addOrEditProductToOrder() {
    if (selectedDate == null) {
      showErrorSnackBar("Please select a date for the order.");
      return;
    }

    if (selectedProductId == null || selectedCustomerId == null) {
      showErrorSnackBar("Please select a product and customer.");
      return;
    }

    final selectedProduct = products.firstWhere(
      (product) => product["prod_id"] == selectedProductId,
      orElse: () => null,
    );

    if (selectedProduct == null) {
      showErrorSnackBar("Invalid product selected.");
      return;
    }

    if (productQuantity <= 0) {
      showErrorSnackBar("Quantity must be greater than 0.");
      return;
    }

    setState(() {
      if (editingProductIndex != null) {
        
        orderProducts[editingProductIndex!] = {
          "Prod_id": selectedProduct["prod_id"],
          "Cust_id": selectedCustomerId,
          "Date": selectedDate?.toIso8601String() ?? '',
          "Total": productQuantity * (selectedProduct['mrp'] ?? 0),
          "Qty": productQuantity,
          "Name": selectedProduct["prod_name"],
          "Price": selectedProduct["mrp"],
          "Stock": selectedProduct["stock"]
        };
        
        editingProductIndex = null;
      } else {
        orderProducts.add({
          "Prod_id": selectedProduct["prod_id"],
          "Cust_id": selectedCustomerId,
          "Date": selectedDate?.toIso8601String() ?? '',
          "Total": productQuantity * (selectedProduct['mrp'] ?? 0),
          "Qty": productQuantity,
          "Name": selectedProduct["prod_name"],
          "Price": selectedProduct["mrp"],
          "Stock": selectedProduct["stock"]
        });
      }
    });

    showSuccessSnackBar(editingProductIndex != null
        ? "Product updated in order!"
        : "Product added to order!");
  }

  void editProduct(int index) {
    final product = orderProducts[index];

    setState(() {
      selectedProductId = product["Prod_id"];
      selectedCustomerId = product["Cust_id"];
      productQuantity = product["Qty"];
      editingProductIndex = index;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Form", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ Color.fromARGB(255, 199, 192, 237),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: selectOrderDate,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 2, 0, 16),),
                  child: Text(
                    selectedDate == null
                        ? "Select Order Date"
                        : "Date: ${selectedDate!.toLocal()}".split(' ')[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Select Customer",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCustomerId,
                  onChanged: (int? value) {
                    setState(() {
                      selectedCustomerId = value!;
                    });
                  },
                  items: customers.map<DropdownMenuItem<int>>((customer) {
                    return DropdownMenuItem<int>(
                      value: customer["id"],
                      child: Text(customer["cust_Name"]),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Select Product",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedProductId,
                  onChanged: (int? value) {
                    setState(() {
                      selectedProductId = value!;
                    });
                  },
                  items: products.map<DropdownMenuItem<int>>((product) {
                    return DropdownMenuItem<int>(
                      value: product["prod_id"],
                      child: Text("${product["prod_name"]} - \$${product["mrp"]}"),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Quantity: ", style: TextStyle(color: Colors.black)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          productQuantity = productQuantity > 1
                              ? productQuantity - 1
                              : productQuantity;
                        });
                      },
                      icon: const Icon(Icons.remove, color: Colors.black),
                    ),
                    Text("$productQuantity", style: const TextStyle(color: Colors.black)),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          productQuantity++;
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: addOrEditProductToOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 0, 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    editingProductIndex != null
                        ? "Edit Product in Order"
                        : "Add Product to Order",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderProducts.length,
                  itemBuilder: (context, index) {
                    final orderProduct = orderProducts[index];
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(orderProduct["Name"], style: const TextStyle(color: Colors.teal)),
                        subtitle: Text(
                            "Qty: ${orderProduct["Qty"]}, Price: \$${orderProduct["Price"]}, Total: \$${orderProduct["Total"]}",
                            style: const TextStyle(color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: () => editProduct(index), 
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 0, 16),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
