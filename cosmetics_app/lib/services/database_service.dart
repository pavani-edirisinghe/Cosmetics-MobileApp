import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET ALL PRODUCTS (Real-time)
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. HELPER: Add Sample Data (Run this once to fill your database)
  Future<void> addDummyData() async {
    final CollectionReference products = _db.collection('products');
    
    // Safety check: Don't add if data already exists
    var snapshot = await products.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    List<Map<String, dynamic>> dummyProducts = [
      {
        "name": "Velvet Red Lipstick",
        "description": "A long-lasting matte lipstick with a rich red hue.",
        "price": 24.99,
        "category": "Makeup",
        "imageUrl": "https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=400&q=80"
      },
      {
        "name": "Hydrating Face Serum",
        "description": "Infused with Vitamin C and Hyaluronic Acid for a natural glow.",
        "price": 45.50,
        "category": "Skincare",
        "imageUrl": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=400&q=80"
      },
      {
        "name": "Rose Gold Palette",
        "description": "12 shimmer and matte shades perfect for day and night.",
        "price": 32.00,
        "category": "Makeup",
        "imageUrl": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=400&q=80"
      },
      {
        "name": "Daily Moisturizer",
        "description": "Lightweight, non-greasy formula suitable for all skin types.",
        "price": 18.99,
        "category": "Skincare",
        "imageUrl": "https://images.unsplash.com/photo-1608248597279-f99d160bfbc8?auto=format&fit=crop&w=400&q=80"
      },
    ];

    for (var p in dummyProducts) {
      await products.add(p);
    }
  }
}