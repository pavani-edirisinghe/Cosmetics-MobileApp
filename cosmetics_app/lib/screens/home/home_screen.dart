import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/product_model.dart';
import '../auth/login_screen.dart';
import 'product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  final dbService = DatabaseService();

  // STATE VARIABLES (To remember what user selected)
  String searchQuery = "";
  String selectedCategory = "All";
  
  // List of categories for the filter buttons
  final List<String> categories = ["All", "Makeup", "Skincare", "Perfume"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Glow Catalog"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. SEARCH BAR
            TextField(
              onChanged: (value) {
                // Update the state whenever user types
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. CATEGORY FILTER (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor, // Pink
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 3. PRODUCT GRID (With Filter Logic)
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: dbService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No products found."));
                  }

                  final allProducts = snapshot.data!;

                  // --- FILTER LOGIC STARTS HERE ---
                  final filteredProducts = allProducts.where((product) {
                    final matchesSearch = product.name.toLowerCase().contains(searchQuery);
                    final matchesCategory = selectedCategory == "All" || product.category == selectedCategory;
                    
                    return matchesSearch && matchesCategory;
                  }).toList();
                  // --- FILTER LOGIC ENDS HERE ---

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text("No items match your search."),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}