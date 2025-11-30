import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../models/review_model.dart'; // Import Review Model
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

// Helper to show the "Write Review" Dialog with Clickable Stars
  void _showReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double selectedRating = 0.0; // Default starts at 5

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder allows us to update the stars INSIDE the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Write a Review"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Tap a star to rate:"),
                  const SizedBox(height: 10),
                  
                  // INTERACTIVE STARS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          // If index is less than rating, show filled star
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          // Update the rating when clicked
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),

                  const SizedBox(height: 10),
                  
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      hintText: "Your comment...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text("Submit"),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && commentCtrl.text.isNotEmpty) {
                      final newReview = ReviewModel(
                        id: '', 
                        userName: user.email!.split('@')[0], 
                        rating: selectedRating, // Now uses the selected stars!
                        comment: commentCtrl.text.trim(),
                        date: DateTime.now(),
                      );

                      await DatabaseService().addReview(product.id, newReview);
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Review Added!")),
                      );
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await DatabaseService().addToWishlist(user.uid, product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to Wishlist!"), backgroundColor: Colors.pink),
                );
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. IMAGE
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),

            // 2. PRODUCT INFO
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(product.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  
                  const SizedBox(height: 20),
                  
                  // ADD TO CART BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        context.read<CartProvider>().addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${product.name} added to cart!"), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  
                  // 3. REVIEWS SECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Write Review"),
                        onPressed: () => _showReviewDialog(context),
                      )
                    ],
                  ),

                  // REVIEWS LIST
                  StreamBuilder<List<ReviewModel>>(
                    stream: dbService.getProductReviews(product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey));
                      }

                      return ListView.builder(
                        shrinkWrap: true, // Important for nested list
                        physics: const NeverScrollableScrollPhysics(), // Disable internal scroll
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final review = snapshot.data![index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(review.userName),
                            subtitle: Text(review.comment),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(review.rating.toString()),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}