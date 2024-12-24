import 'package:flutter/material.dart';
import 'package:shopme/screens/Product/ProductService.dart';
import 'package:shopme/screens/Product/Stock.dart';
import 'package:shopme/screens/Product/ViewProduct.dart';
import 'package:shopme/screens/home.dart';

void main() => runApp(const ProductPageApp());

class ProductPageApp extends StatelessWidget {
  const ProductPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProductPage1(),
    );
  }
}

class ProductPage1 extends StatefulWidget {
  const ProductPage1({super.key});

  @override
  _ProductPage1State createState() => _ProductPage1State();
}

class _ProductPage1State extends State<ProductPage1> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MenuCardPage(),
    const Center(
      child: Text(
        'Home Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
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
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 2, 0, 16),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
      ),
    );
  }
}

class MenuCardPage extends StatelessWidget {
  const MenuCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildMenuCard(
                icon: Icons.visibility,
                title: 'View Products',
                color: const Color.fromARGB(255, 2, 0, 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewProductPage()),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.add_circle_outline,
                title: 'Add Products',
                color: const Color.fromARGB(255, 2, 0, 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPage()),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.shopping_basket,
                title: 'Products',
                color: const Color.fromARGB(255, 2, 0, 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StockPage()),
                  );
                },
              ),
              _buildMenuCard(
                icon: Icons.settings_accessibility,
                title: 'Settings',
                color: const Color.fromARGB(255, 2, 0, 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 6.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32.0,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
