import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart'; 

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET ALL PRODUCTS
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. HELPER: Add Sample Data
  Future<void> addDummyData() async {
    final CollectionReference products = _db.collection('products');
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
        "description": "Infused with Vitamin C and Hyaluronic Acid.",
        "price": 45.50,
        "category": "Skincare",
        "imageUrl": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=400&q=80"
      },
      {
        "name": "Rose Gold Palette",
        "description": "12 shimmer and matte shades.",
        "price": 32.00,
        "category": "Makeup",
        "imageUrl": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=400&q=80"
      },
      {
        "name": "Daily Moisturizer",
        "description": "Lightweight, non-greasy formula.",
        "price": 18.99,
        "category": "Skincare",
        "imageUrl": "https://images.unsplash.com/photo-1608248597279-f99d160bfbc8?auto=format&fit=crop&w=400&q=80"
      },
    ];

    for (var p in dummyProducts) {
      await products.add(p);
    }
  }

  // 3. PLACE ORDER 
  Future<void> placeOrder(String userId, double total, List<dynamic> items) async {
    await _db.collection('orders').add({
      'userId': userId,
      'total': total,
      'status': 'Pending',
      'date': Timestamp.now(),
      'items': items,
    });
  }

  // 4. GET MY ORDERS
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 5. ADD TO WISHLIST
  Future<void> addToWishlist(String userId, Product product) async {
    // We use .set() with the product ID so we don't get duplicates
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id)
        .set(product.toMap());
  }

  // 6. REMOVE FROM WISHLIST
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  // 7. GET MY WISHLIST
  Stream<List<Product>> getWishlist(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}