import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewProductPage extends StatefulWidget {
  @override
  _ViewProductPageState createState() => _ViewProductPageState();
}

class _ViewProductPageState extends State<ViewProductPage> {
  final String apiUrl = "https://localhost:7233/api/Product"; 
  List products = [];
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts();
    });
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body) ?? [];
        });
      } else {
        showSnackBar("Error fetching products: ${response.statusCode}");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

 
  Future<void> editProduct(Map<String, dynamic> product) async {
    final TextEditingController nameController =
        TextEditingController(text: product['prod_name']);
    final TextEditingController mrpController =
        TextEditingController(text: product['mrp'].toString());
    final TextEditingController stockController =
        TextEditingController(text: product['stock'].toString());

    final int id = product['prod_id'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField(nameController, "Product Name"),
                const SizedBox(height: 10),
                buildTextField(mrpController, "MRP"),
                const SizedBox(height: 10),
                buildTextField(stockController, "Stock"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await http.put(
                    Uri.parse("$apiUrl/$id"), 
                    headers: {"Content-Type": "application/json"},
                    body: json.encode({
                      "prod_id": id,
                      "prod_name": nameController.text,
                      "mrp": double.parse(mrpController.text),
                      "stock": int.parse(stockController.text),
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 204) {
                    await fetchProducts(); 
                    if (mounted) {
                      Navigator.pop(context); 
                      showSnackBar("Product updated successfully!");
                    }
                  } else {
                    showSnackBar("Error updating product: ${response.body}");
                  }
                } catch (e) {
                  showSnackBar("Error: $e");
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  
  Future<void> deleteProduct(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse("$apiUrl/$id"));
        if (response.statusCode == 200 || response.statusCode == 204) {
          await fetchProducts(); 
          showSnackBar("Product deleted successfully!");
        } else {
          showSnackBar("Error deleting product: ${response.statusCode}");
        }
      } catch (e) {
        showSnackBar("Error: $e");
      }
    }
  }

  
  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:const Color.fromARGB(255, 2, 0, 16),
                      child: Text(
                        products[index]['prod_name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(products[index]['prod_name']),
                    subtitle: Text(
                      "MRP: ₹${products[index]['mrp']}\n"
                      "Stock: ${products[index]['stock']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editProduct(products[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteProduct(products[index]['prod_id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  
  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: label == "MRP" || label == "Stock"
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(25),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}
