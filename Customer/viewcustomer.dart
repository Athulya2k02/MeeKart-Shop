import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewCustomerPage extends StatefulWidget {
  const ViewCustomerPage({super.key});

  @override
 
  _ViewCustomerPageState createState() => _ViewCustomerPageState();
}

class _ViewCustomerPageState extends State<ViewCustomerPage> {
  final String apiUrl = "https://localhost:7233/api/Customer"; 
  List customers = [];
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCustomers();
    });
  }

  Future<void> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          customers = json.decode(response.body) ?? [];
        });
      } else {
        showSnackBar("Error fetching customers: ${response.statusCode}");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  Future<void> editCustomer(Map<String, dynamic> customer) async {
    final TextEditingController nameController =
        TextEditingController(text: customer['cust_Name']);
    final TextEditingController addressController =
        TextEditingController(text: customer['cust_address']);
    final TextEditingController cityController =
        TextEditingController(text: customer['city']);
    final TextEditingController itemsController =
        TextEditingController(text: customer['items'].toString());
    final TextEditingController phoneNumberController =
        TextEditingController(text: customer['phone_number']?.toString() ?? "");

    final int id = customer['id'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Customer"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTextField(nameController, "Name"),
                const SizedBox(height: 10),
                buildTextField(addressController, "Address"),
                const SizedBox(height: 10),
                buildTextField(cityController, "City"),
                const SizedBox(height: 10),
                buildTextField(itemsController, "Items"),
                const SizedBox(height: 10),
                buildTextField(phoneNumberController, "Phone Number"),
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
                      "id": id,
                      "cust_Name": nameController.text,
                      "cust_address": addressController.text,
                      "city": cityController.text,
                      "items": itemsController.text,
                      "phone_number": phoneNumberController.text,
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 204) {
                    await fetchCustomers();
                    if (mounted) {
                      Navigator.pop(context);
                      showSnackBar("Customer updated successfully!");
                    }
                  } else {
                    showSnackBar("Error updating customer: ${response.body}");
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

  Future<void> deleteCustomer(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this customer?"),
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
          fetchCustomers();
          showSnackBar("Customer deleted successfully!");
        } else {
          showSnackBar("Error deleting customer: ${response.statusCode}");
        }
      } catch (e) {
        showSnackBar("Error: $e");
      }
    }
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.startsWith("Error") ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16), 
        elevation: 8,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: customers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: Colors.teal[50],  
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
                        child: Text(
                          customers[index]['cust_Name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        customers[index]['cust_Name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      subtitle: Text(
                        "Address: ${customers[index]['cust_address']}\n"
                        "City: ${customers[index]['city']}\n"
                        "Items: ${customers[index]['items']}\n"
                        "Phone: ${customers[index]['phone_number'] ?? 'N/A'}",
                        style: const TextStyle(color: Color.fromARGB(255, 2, 0, 16),),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editCustomer(customers[index]),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteCustomer(customers[index]['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[800]),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
