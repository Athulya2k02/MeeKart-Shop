import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List products = [];
  List filteredProducts = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse("https://localhost:7233/api/Product"));
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        setState(() {
          products = responseBody;
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        showErrorSnackBar("Error fetching products: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showErrorSnackBar("Error fetching products: $e");
    }
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> updateStock(int productId) async {
    try {
      final product = products.firstWhere((p) => p['id'] == productId);
      if (product['stock'] > 0) {
        product['stock']--;
        final response = await http.put(
          Uri.parse('https://localhost:7233/api/Product/$productId'),
          body: json.encode({'id': productId, 'Stock': product['stock']}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          setState(() {});
        } else {
          showErrorSnackBar("Error updating stock: ${response.statusCode}");
        }
      } else {
        showErrorSnackBar("Product is out of stock.");
      }
    } catch (e) {
      showErrorSnackBar("Error updating stock: $e");
    }
  }

  Future<void> createOrder(int productId) async {
    try {
      final product = products.firstWhere((p) => p['id'] == productId);
      final response = await http.post(
        Uri.parse('https://localhost:7233/api/Order'),
        body: json.encode({
          'productId': productId,
          'productName': product['prod_name'],
          'quantity': 1,
          'price': product['mrp'],
          'date': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")),
        );
      } else {
        showErrorSnackBar("Error placing order: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error placing order: $e");
    }
  }

  String getProductImage(String productName) {
    switch (productName) {
      case 'Leggings':
        return "https://vnhnaiduhall.com/cdn/shop/files/1_003b74f5-45f5-44ff-af34-11a5b71514ff.jpg?v=1726213245";
      case 'Shoe':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnDmiV5rmcZknTwx-IraHgQYai5OYpWufw6g&s";
      case 'Kurthi':
        return "https://vnhnaiduhall.com/cdn/shop/files/1_003b74f5-45f5-44ff-af34-11a5b71514ff.jpg?v=1726213245";
      case 'Chocolates':
        return "https://t4.ftcdn.net/jpg/09/15/49/09/360_F_915490907_8j12cSGhgChpxn9RZYNnmTuj7lM39L8T.jpg";
      case 'Product A':
        return "https://vnhnaiduhall.com/cdn/shop/files/1_003b74f5-45f5-44ff-af34-11a5b71514ff.jpg?v=1726213245";
      case 'Serum':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6UQAKwlNlrrUApzx112NBZEuUvJ-XTe4";
      case 'Foundation':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTv8spQqUXiu6xrobiOGLweE0rGzA9WrkczxA&s";
      case 'Groceries':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHxE-diVJtzNIhW3NcnzEOEVAwRAskpXc8ow&s";
      case 'Lipstick':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTv8spQqUXiu6xrobiOGLweE0rGzA9WrkczxA&s";
      case 'Mens Shirt':
        return "https://rukminim2.flixcart.com/image/850/1000/xif0q/shirt/1/z/c/xl-plain-shirt-for-mens-shiv-fashion-original-imaghffh7rm2hvhr.jpeg?q=90&crop=false";
      default:
        return "https://via.placeholder.com/150";
    }
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = products;
      });
    } else {
      setState(() {
        filteredProducts = products.where((product) {
          return product['prod_name'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(() {
      filterProducts(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 250,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredProducts.isEmpty
              ? const Center(child: Text("No products found", style: TextStyle(fontSize: 18, color: Colors.grey)))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filteredProducts[index];
                    String imageUrl = getProductImage(product['prod_name']);
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.teal.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['prod_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                                color: Colors.teal.shade800,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'MRP: ₹${product['mrp']}',
                              style: TextStyle(color: Colors.teal.shade600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Stock: ${product['stock']}',
                                  style: TextStyle(
                                    color: product['stock'] > 0
                                        ? Colors.teal.shade800
                                        : Colors.red,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (product['stock'] > 0) {
                                      await updateStock(product['id']);
                                      await createOrder(product['id']);
                                    } else {
                                      showErrorSnackBar("Product is out of stock.");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 2, 0, 16),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    product['stock'] > 0 ? "placeOrder" : "Out of Stock",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
