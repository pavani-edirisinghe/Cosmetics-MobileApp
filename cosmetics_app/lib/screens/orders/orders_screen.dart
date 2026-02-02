import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Helps format dates (You might need to add intl to pubspec)
import '../../services/database_service.dart';
import '../../models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final dbService = DatabaseService();

    if (user == null)
      return const Scaffold(body: Center(child: Text("Please Login")));

    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: const Text("Track My Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),
      ),
    ),

      body: StreamBuilder<List<OrderModel>>(
        stream: dbService.getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_shipping_outlined, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text("You haven't placed any orders yet!"),
                  ],
                ),
              );
            }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // Requires intl package, or just use order.date.toString()
                            DateFormat('MMM dd, yyyy').format(order.date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: order.status == 'Pending'
                                  ? Colors.amber.shade200
                                  : order.status == 'Shipped'
                                      ? Colors.blue.shade200
                                      : Colors.green.shade200, // Delivered
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                color: order.status == 'Pending'
                                    ? const Color.fromARGB(255, 191, 45, 45)
                                    : order.status == 'Shipped'
                                        ? const Color.fromARGB(255, 9, 49, 95)
                                        : const Color.fromARGB(255, 21, 108, 26), // Delivered
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text(
                                "1x ",
                                style: TextStyle(color: const Color.fromARGB(255, 139, 65, 117), fontSize: 17),
                              ),
                              Expanded(child: Text(item['name'])),
                              Text("Rs.${item['price']}"),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Paid",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Rs.${order.total.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
