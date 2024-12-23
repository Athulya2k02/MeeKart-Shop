import 'package:flutter/material.dart';
import 'package:shopme/screens/Customer/CustomerService.dart';  
import 'package:shopme/screens/Customer/Cart.dart';
import 'package:shopme/screens/Customer/viewcustomer.dart'; 

void main() => runApp(const CustomerApp());

class CustomerPageApp extends StatelessWidget {
  const CustomerPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CustomerPage1(),
    );
  }
}

class CustomerPage1 extends StatefulWidget {
  const CustomerPage1({super.key});

  @override
  _CustomerPage1State createState() => _CustomerPage1State();
}

class _CustomerPage1State extends State<CustomerPage1> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MenuCardPage(),
    const Center(
      child: Text(
        'Order History Page',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        'Add Customer Page',
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
          'Customer Page',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 2, 0, 16),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 199, 192, 237),
              Color.fromARGB(255, 255, 255, 255),
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
        backgroundColor: Color.fromARGB(255, 2, 0, 16),
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
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 50.0,
        mainAxisSpacing: 50.0,
        children: [
          _buildMenuCard(
            icon: Icons.visibility,
            title: 'View Customers',
            color: const Color.fromARGB(255, 2, 0, 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const ViewCustomerPage()),
              );
            },
          ),
             _buildMenuCard(
            icon: Icons.add_circle_outline,
            title: 'Add Customers',
            color: const Color.fromARGB(255, 2, 0, 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const CustomerPage()),
              );
            },
          ),
             _buildMenuCard(
            icon: Icons.shop_2,
            title: 'Order History',
            color: const Color.fromARGB(255, 2, 0, 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const OrderHistoryPage()),
              );
            },
          ),
             _buildMenuCard(
            icon: Icons.settings_accessibility,
            title: 'Settings',
            color:  const Color.fromARGB(255, 2, 0, 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const HomePage()),
              );
            },
          ),
          
        ],
      ),
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
          borderRadius: BorderRadius.circular(6.0),
        ),
        elevation: 8.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.0,
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
