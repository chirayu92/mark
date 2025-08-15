import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mark/pages/CheckOut.dart';
class Cartpage extends StatefulWidget {
  const Cartpage({super.key});

  @override
  State<Cartpage> createState() => _CartpageState();
}

class _CartpageState extends State<Cartpage> {

  bool check = false;

  void changeCheck(String docId,bool check )async{

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(docId)
        .update({'check':check},
    );
  }

  Future<void> updateCart(String docId, int qty)async{
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(docId).update(
        {'qty':qty,});
  }

  double calculateTotal(List<QueryDocumentSnapshot> items) {
    double total=0.0;
    for(var item in items){
      final data = item.data() as Map<String,dynamic>;
      final price = double.tryParse(item['Price'].toString()) ?? 0;
      final qty = item['qty'];
      total += price * qty;
    }
    return total;
  }
  Future<void> proceedToCheckout(List<QueryDocumentSnapshot> items, double totalPrice) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    List<Map<String, dynamic>> selectedItems = items.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'Name': data['Name'],
        'Price': data['Price'],
        'qty': data['qty'] ?? 1,
        'image': data['image'],
      };
    }).toList();


    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=>CheckoutPage(selectedItems, totalPrice))
    );


    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout completed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null){
      return const Scaffold(body : Center( child: Text( "please log in to view your cart.")),
      );
    }
    final uid = user.uid;
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: Text("Cart page"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cart')
            .where('isCheckout', isEqualTo: false)
            .snapshots(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError){
            return Center(child: Text("Something went wrong: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center (child: Text ("Your cart is empty"));
          }
          final items = snapshot.data!.docs;
          final selectedItems = snapshot.data!.docs.where((doc) {
            return doc.get('check') == true;
          }).toList();
          final totalPrice= calculateTotal(selectedItems);
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context,index){
                      final data = items[index].data() as Map<String,dynamic>;
                      final qty = data['qty'];
                      final docId = items[index].id;
                      return Card(
                        child: ListTile(
                          leading: Image.memory(base64Decode(data['image']),height: 50,width: 60,),
                          title: Text(data['Name']),
                          subtitle: Text("Price: Rs ${data['Price']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(value: data['check'], onChanged: (bool? newValue) {
                                setState(() {
                                  changeCheck(data['Name'],newValue!);
                                });
                              },),
                              IconButton(
                                  onPressed: (){
                                    if(qty>1){
                                      updateCart(docId, qty-1);
                                    }
                                    else{
                                      FirebaseFirestore.instance.collection('users')
                                          .doc(uid)
                                          .collection('cart')
                                          .doc(docId)
                                          .delete();
                                    }
                                  },
                                  icon: Icon(Icons.remove)
                              ),
                              Text(data['qty'].toString()),
                              IconButton(
                                  onPressed: (){
                                    updateCart(docId, qty+1);
                                  },
                                  icon: Icon(Icons.add)
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: Rs. ${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: (){
                        proceedToCheckout(items, totalPrice);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Checkout",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    ));
  }
}
