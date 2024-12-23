import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const CustomerApp());

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CustomerPage(),
    );
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final String apiUrl = "https://localhost:7233/api/Customer";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController itemsController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isNameValid = true;
  bool isPhoneValid = true;

  Future<List> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        showErrorSnackBar("Error fetching customers: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error: $e");
    }
    return [];
  }

 Future<void> addCustomer() async {
  setState(() {
    isNameValid = nameController.text.isNotEmpty;
    isPhoneValid = phoneNumberController.text.isNotEmpty;
  });

  if (!isNameValid || !isPhoneValid) {
    showErrorSnackBar("* Please fill all required fields");
    return;
  }

  const phoneRegex = r'^[0-9]{10}$';
  final isValidPhone = RegExp(phoneRegex).hasMatch(phoneNumberController.text);
  
  if (!isValidPhone) {
    setState(() {
      isPhoneValid = false;
    });
    showErrorSnackBar("Invalid phone number. Please enter a 10-digit phone number.");
    return;
  }

  final customers = await fetchCustomers();
  if (customers.any((cust) =>
      cust['phone_number'] == phoneNumberController.text)) {
    showErrorSnackBar("Phone number already exists.");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "cust_Name": nameController.text,
        "cust_address": addressController.text,
        "city": cityController.text,
        "items": itemsController.text,
        "phone_number": phoneNumberController.text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      showSuccessSnackBar("Customer added successfully!");
      clearForm();
      Navigator.pop(context);
    } else {
      showErrorSnackBar("Error adding customer: ${response.statusCode}");
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
        title: const Text(
          "Customer Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Customer",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(0, 150, 136, 1),
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
                    onPressed: addCustomer,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add Customer",
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
          buildTextField(nameController, "Name", TextInputType.text, !isNameValid, Icons.person),
          const SizedBox(height: 15),
          buildTextField(addressController, "Address", TextInputType.text, false, Icons.home),
          const SizedBox(height: 15),
          buildTextField(cityController, "City", TextInputType.text, false, Icons.location_city),
          const SizedBox(height: 15),
          buildTextField(itemsController, "Items", TextInputType.text, false, Icons.shopping_cart),
          const SizedBox(height: 15),
          buildTextField(phoneNumberController, "Phone Number", TextInputType.phone, !isPhoneValid, Icons.phone),
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
          borderSide:const  BorderSide(color: Colors.teal),
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

  void clearForm() {
    nameController.clear();
    addressController.clear();
    cityController.clear();
    itemsController.clear();
    phoneNumberController.clear();
  }
}
