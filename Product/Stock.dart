import 'dart:async';
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
  Timer? debounce;

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

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      filterProducts(query);
    });
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

  String getProductImage(String productName) {
      switch (productName) {
      case 'Leggings':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKQGQ1JDvVvbpToNX-OxWOskunGhpy63JwqA&s";
      case 'Shoe':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSnDmiV5rmcZknTwx-IraHgQYai5OYpWufw6g&s";
      case 'Kurthi':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSoaGbck34wn5fi3xWsU1Lv0nllVr4zKtotuQ&s";
      case 'Chocolates':
        return "https://t4.ftcdn.net/jpg/09/15/49/09/360_F_915490907_8j12cSGhgChpxn9RZYNnmTuj7lM39L8T.jpg";
      case 'Product A':
        return "https://vnhnaiduhall.com/cdn/shop/files/1_003b74f5-45f5-44ff-af34-11a5b71514ff.jpg?v=1726213245";
      case 'serum':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR2pEnIrsMSDvq3AuCK9rW_X0P6ZFlFALeKew&s";
      case 'Foundation':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTv8spQqUXiu6xrobiOGLweE0rGzA9WrkczxA&s";
      case 'Groceries':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHxE-diVJtzNIhW3NcnzEOEVAwRAskpXc8ow&s";
      case 'Lipstick':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYrNusP6JGtPYLicEpxGpYgzCFh66EKu9p_Q&s";
      case 'soap':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTE-KAjvmXeNktN_qE4wR4yciw5MepVDyg49w&s";
      case 'Bags':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTldrC1FSb3N12LN2tn13Xpo9A5auoUto1Zaw&s";
      case 'Books':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3V0YsufdoIW1lYYGOVc9Z1pt3u7h80fWhFw&s";
      case 'Bottles':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQL75xu_KtjGbJyPvtgWeQ0mNVg8wLR3MFhdA&s";
      case 'PenHolder':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQmTdt3wziL8mAktOR148LjgzlGP8vhR2pTJw&s";
      case 'Mens Shirt':
        return "https://rukminim2.flixcart.com/image/850/1000/xif0q/shirt/1/z/c/xl-plain-shirt-for-mens-shiv-fashion-original-imaghffh7rm2hvhr.jpeg?q=90&crop=false";
         case 'Kidswear(Girls)':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuQE00pwSNmlzh-hks8ID_dIKaA4dRvLS63g&s";
      case 'Kidswear(Boys)':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQzcfpDRPWZDV1UeC_wBtrKYBUfb8Xs2teOg&s";
      case 'Toys':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLu-uuUkmUlvl3A8eG7Vi6xgdBy7RENOs8PQ&s";
      case 'Saree':
        return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpo2xv9fee9r380YNUowgKPH7ySZYCT6ppMA&s";
    default:

    return "https://via.placeholder.com/150";
  }
  }
  void updateStock(int productId, int currentStock) async {
    if (currentStock <= 0) {
      showErrorSnackBar("Product is out of stock");
      return;
    }

    try {
      final updatedStock = currentStock - 1;
      final response = await http.put(
        Uri.parse("https://localhost:7233/api/Product/$productId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"stock": updatedStock}),
      );

      if (response.statusCode == 200) {
        setState(() {
        final index = products.indexWhere((p) => p['id'] == productId);
       if (index != -1) {
       products[index]['stock'] = updatedStock;
       filterProducts(searchController.text);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock updated successfully!")),
        );
      } else {
        showErrorSnackBar("Failed to update stock: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackBar("Error updating stock: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
      title: const Text('Product Catalog', style: TextStyle(color: Colors.white),),
      backgroundColor: const Color.fromARGB(255, 2, 0, 16),
      actions: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
      width: screenWidth > 600 ? 300 : 200,
      child: TextField(
      controller: searchController,
      decoration: InputDecoration(
      hintText: 'Search products...',
      prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 2, 0, 16),),
      border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 253, 255, 254),
                ),
              ),
            ),
          ),
        ],
      ),
       body: Container(
       decoration: const BoxDecoration(
        gradient: LinearGradient(
        colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 8, 1, 52)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      child: isLoading
      ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 8, 1, 52)))
      : filteredProducts.isEmpty? 
      const Center(
      child: Text(
                    "No products found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = screenWidth > 1200 ? 4
                        : screenWidth > 800 ? 3 : 2;

        return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
                      ),
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
        var product = filteredProducts[index];
        String imageUrl = getProductImage(product['prod_name']);

        return Card(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
                          ),
        color: const Color.fromARGB(255, 242, 241, 244),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
                     ClipRRect(
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                     child: Image.network(
                     imageUrl,
                     height: constraints.maxWidth / crossAxisCount * 0.5,
                     width: double.infinity,
                     fit: BoxFit.cover,
                     errorBuilder: (context, error, stackTrace) {
                     return const Icon(Icons.error, size: 50);
                                  },
                                ),
                              ),
                     Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(
                     product['prod_name'],
                    style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 600 ? 18 : 14,
                    color: Color.fromARGB(255, 8, 1, 52)
                            ),
                     overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                              'MRP: ₹${product['mrp']}',
                               style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Text(
                                      'Stock: ${product['stock']}',
                                      style: TextStyle(
                                        color: product['stock'] > 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 8, 1, 52)
                                      ),
                                      onPressed: () {
                                      updateStock(product['id'], product['stock']);
                                      },
                                      child: Text(product['stock'] > 0 ? "Buy" : "Out of Stock"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
       )
    );
  }
}
