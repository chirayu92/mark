import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderSummaryPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalPrice;
  final double transportFee;

  const OrderSummaryPage({
    required this.items,
    required this.totalPrice,
    this.transportFee = 0,
    super.key,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveOrderToFirebase();
  }

  Future<void> _saveOrderToFirebase() async {
    if (_isSaved) return; // prevent duplicate saves
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // user not logged in

    final grandTotal = widget.totalPrice + widget.transportFee;

    try {
      await FirebaseFirestore.instance
          .collection('users')           // under users
          .doc(user.uid)                 // current user UID
          .collection('orders')          // user's orders subcollection
          .add({
        'items': widget.items,
        'totalPrice': widget.totalPrice,
        'transportFee': widget.transportFee,
        'grandTotal': grandTotal,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSaved = true;
      });
      print("Order saved under user ${user.uid}!");
    } catch (e) {
      print("Failed to save order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = widget.totalPrice + widget.transportFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 12),
          const Text(
            "Thank You!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Your order has been placed successfully.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final qty = int.tryParse(item['qty'].toString()) ?? 1;
                final price = double.tryParse(item['Price'].toString()) ?? 0;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(item['image']),
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['Name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rs ${price.toStringAsFixed(2)} x $qty = Rs ${(price * qty).toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Transportation Fee: Rs. ${widget.transportFee.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total Paid: Rs. ${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
