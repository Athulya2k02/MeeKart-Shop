import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopme/screens/Product/viewproduct.dart';

void main() => runApp(ProductApp());

class ProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final String apiUrl = "https://localhost:7233/api/Product";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> addProduct() async {
    try {
      final body = {
        "Prod_id": 0,
        "prod_name": nameController.text,
        "MRP": double.parse(mrpController.text),
        "stock": int.parse(stockController.text),
      };

      print("Request Body: $body");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessSnackBar("Product added successfully!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewProductPage()),
        );
        clearFormFields();
      } else {
        showErrorSnackBar("Error adding product: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
      print("Exception: $e");
    }
  }

  void clearFormFields() {
    nameController.clear();
    mrpController.clear();
    stockController.clear();
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
        title: const Text("Add Product",style: TextStyle(color:Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildForm(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: addProduct,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add Product",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 0, 16),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextField(nameController, "Product Name", TextInputType.text, false, Icons.shopping_bag),
          const SizedBox(height: 15),
          buildTextField(mrpController, "MRP", TextInputType.number, false, Icons.attach_money),
          const SizedBox(height: 15),
          buildTextField(stockController, "Stock", TextInputType.number, false, Icons.inventory),
        ],
      ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, TextInputType type, bool hasError, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(25),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(25),
        ),
        errorText: hasError ? "* This field is required" : null,
        errorBorder: hasError
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              )
            : null,
      ),
      keyboardType: type,
    );
  }
}
