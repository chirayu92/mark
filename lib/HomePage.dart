import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mark/Categories/Babies.dart';
import 'package:mark/Categories/Child.dart';
import 'package:mark/Categories/Men.dart';
import 'package:mark/Categories/Women.dart';
import 'package:mark/Profile.dart';
import 'package:mark/login.dart';
import 'package:mark/pages/CartPage.dart';
import 'package:mark/pages/ItemsAdd.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String? name;
  String? base64Image;
  bool loadingImage = true;

  @override
  void initState() {
    super.initState();
    getData();
    loadUserImage();
  }
  Future<void> loadUserImage() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        base64Image = null;
        loadingImage = false;
      });
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          base64Image = doc.data()?['image'];
          loadingImage = false;
        });
      } else {
        setState(() {
          base64Image = null;
          loadingImage = false;
        });
      }
    } catch (e) {
      setState(() {
        base64Image = null;
        loadingImage = false;
      });
    }
  }


  void getData()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("Name");
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addToCart(Map<String,dynamic> product) async {
    final user = _auth.currentUser;
    final cartRef = _firestore.collection('users').doc(user!.uid).collection(
        'cart').doc(product['Name']);

    final docSnapshot = await cartRef.get();
    if (docSnapshot.exists) {
      final currentQty = docSnapshot.data()?['qty'] ?? 1;
      await cartRef.update({'qty': currentQty + 1,});
    }
    else {
      await cartRef.set({
        'Name': product['Name'],
        'Price': product['Price'],
        'Discription': product['Discription'],
        'image': product['image'],
        'qty': 1,
        'isCheckout': false,
        'isDelivered': false,
        'check':false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Haat Bazar",style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 35,
          color: Colors.red,
        ),),
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => profile()),
              );
              }, child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: (loadingImage || base64Image == null) ? null : MemoryImage(base64Decode(base64Image!)),
            child: (loadingImage || base64Image == null) ? Icon(Icons.person_outline, color: Colors.grey, size: 30) : null,
            ),
          ),
        ),
        actions: [
         IconButton(
             onPressed: (){
               Navigator.push(context, MaterialPageRoute(
                   builder: (context)=>Cartpage()));},
             icon: Icon(Icons.shopping_cart)),
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>Items()));},
              icon: Icon(Icons.add))
        ],
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Flash Sale",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
              ),
              ),
              Container(
                  height: 350,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Flash').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      // return GridView.builder(
                      //   padding: const EdgeInsets.all(10),
                      //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      //     crossAxisCount: 2,
                      //     mainAxisSpacing: 10,
                      //     crossAxisSpacing: 10,
                      //     childAspectRatio: 0.7,
                      //   ),
                      //   itemCount: docs.length,
                      //   itemBuilder: (context, index) {
                      //     final data = docs[index].data() as Map<String, dynamic>;
                      //     return Container(
                      //       color: Colors.white,
                      //       child: GestureDetector(
                      //         onTap: () {
                      //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>Productdetailpage(
                      //           //     data['name'],data['description'],data['price'],data['image']
                      //           //
                      //           // )));
                      //         },
                      //         child: Card(
                      //           elevation: 4,
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(12)),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.stretch,
                      //             children: [
                      //               Expanded(
                      //                 child: data['image'] != null && data['image'] != ""
                      //                     ? Image.memory(
                      //                   base64Decode(data['image']),
                      //                   fit: BoxFit.cover,
                      //                 )
                      //                     : const Icon(Icons.image, size: 80),
                      //               ),
                      //               Container(
                      //                 color: Colors.white38,
                      //                 child: Row(
                      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                   children: [
                      //                     // Text(data['name'] ?? "No Name",
                      //                     //     style: const TextStyle(
                      //                     //         fontWeight: FontWeight.bold)),
                      //                     Text("Rs .${data['Price'] ?? 'N/A'}",style: TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       color: Colors.deepOrange,
                      //                     ),),
                      //                     Container(
                      //                       padding: const EdgeInsets.symmetric(
                      //                           horizontal: 3, vertical: 1),
                      //                       decoration: BoxDecoration(
                      //                         color: Colors.deepOrange,
                      //                         borderRadius: BorderRadius.circular(6),
                      //                       ),
                      //                       child: Text("-80%",
                      //                         style: const TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize: 12,
                      //                         ),
                      //                       ),
                      //                     )
                      //                   ],
                      //                 ),
                      //               ),
                      //
                      //               // ElevatedButton(
                      //               //   onPressed: () {
                      //               //  addtocart(
                      //               //      data['name'],
                      //               //      data['price'],
                      //               //      data['description'],
                      //               //      data["color"],
                      //               //      data['image']);
                      //               //   },
                      //               //   child: Text("Add to cart"),
                      //               // ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
                      return SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: GestureDetector(
                                onTap: () {
                                  // Open product detail here
                                },
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: data['image'] != null && data['image'] != ""
                                            ? ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: Image.memory(
                                            base64Decode(data['image']),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : const Icon(Icons.image, size: 80),
                                      ),
                                      Container(
                                        color: Colors.white38,
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(data["Name"] ?? "No Name"),
                                              Text("Rs. ${data['Price'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.deepOrange,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              // child: const Text(
                                              //   "-80%",
                                              //   style: TextStyle(
                                              //     color: Colors.white,
                                              //     fontSize: 12,
                                              //   ),
                                              // ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton(
                                          onPressed: (){
                                            addToCart(data);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${data['Name']} added to cart')),);


                                          },
                                          child: Text("Add to Cart")),
                                    ],
                                  ),

                                ),
                              ),
                            );

                          },
                        ),
                      );


                    },
                  ),
              ),
              //SingleChildScrollView(
                //scrollDirection: Axis.horizontal,
                //child: Row(
                  //children: [
                //Card(
                //child: Padding(
                //padding: const EdgeInsets.all(16),
                //child: Column(
                  //children: [
                   // Image.asset("assets/item/sunglass.webp",height: 120,),
                   // Text("Sunglass"),
                   // Text("Rs. 500 "),
                   // ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
                  //],
                //),
              //),
    //),
                   // Card(child: Padding(
                        //padding: const EdgeInsets.all(16.0),
                        //child: Column(
                          //children: [
                            //Image.asset("assets/item/ball.jpg",height: 120,),
                            //Text("Ball"),
                            //Text("Rs. 100"),
                            //ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
                          //],
                        //),
                      //),
                    //), Card(
                      //child: Padding(
                        //padding: const EdgeInsets.all(16.0),
                        //child: Column(
                          //children: [
                            //Image.asset("assets/item/bag.jpeg",height: 120,),
                            //Text("Bag"),
                            //Text("Rs. 700"),
                            //ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
                          //],
                        //),
                      //),
                    //),
                   // Card(
                     // child: Padding(
                       // padding: const EdgeInsets.all(16.0),
                       // child: Column(
                       //   children: [
                         //   Image.asset("assets/item/mug.webp",height : 120,),
                         //   Text("Mug"),
                         //   Text("Rs. 300"),
                         //   ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
                        //  ],
                      //  ),
                     // ),
                   // )
               // ],),
              //),
              //SizedBox(height: 100,),

              Text("Summer Sale",style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange
              ),),
              Container(
                height: 350,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Summer').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    return SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () {
                                // Open product detail here
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: data['image'] != null && data['image'] != ""
                                          ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.memory(
                                          base64Decode(data['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : const Icon(Icons.image, size: 80),
                                    ),
                                    Container(
                                      color: Colors.white38,
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(data["Name"] ?? "No Name"),
                                          Text("Rs. ${data['Price'] ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            // child: const Text(
                                            //   "-80%",
                                            //   style: TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: 12,
                                            //   ),
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton(
                                        onPressed: (){
                                          addToCart(data);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${data['Name']} added to cart')),);


                                        },
                                        child: Text("Add to Cart")),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );

                    // return GridView.builder(
                    //   padding: const EdgeInsets.all(10),
                    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2,
                    //     mainAxisSpacing: 10,
                    //     crossAxisSpacing: 10,
                    //     childAspectRatio: 0.7,
                    //   ),
                    //   itemCount: docs.length,
                    //   itemBuilder: (context, index) {
                    //     final data = docs[index].data() as Map<String, dynamic>;
                    //     return Container(
                    //       color: Colors.white,
                    //       child: GestureDetector(
                    //         onTap: () {
                    //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>Productdetailpage(
                    //           //     data['name'],data['description'],data['price'],data['image']
                    //           //
                    //           // )));
                    //         },
                    //         child: Card(
                    //           elevation: 4,
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12)),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                    //             children: [
                    //               Expanded(
                    //                 child: data['image'] != null && data['image'] != ""
                    //                     ? Image.memory(
                    //                   base64Decode(data['image']),
                    //                   fit: BoxFit.cover,
                    //                 )
                    //                     : const Icon(Icons.image, size: 80),
                    //               ),
                    //               Container(
                    //                 color: Colors.white38,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     // Text(data['name'] ?? "No Name",
                    //                     //     style: const TextStyle(
                    //                     //         fontWeight: FontWeight.bold)),
                    //                     Text("Rs .${data['Price'] ?? 'N/A'}",style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.deepOrange,
                    //                     ),),
                    //                     Container(
                    //                       padding: const EdgeInsets.symmetric(
                    //                           horizontal: 3, vertical: 1),
                    //                       decoration: BoxDecoration(
                    //                         color: Colors.deepOrange,
                    //                         borderRadius: BorderRadius.circular(6),
                    //                       ),
                    //                       child: Text("-80%",
                    //                         style: const TextStyle(
                    //                           color: Colors.white,
                    //                           fontSize: 12,
                    //                         ),
                    //                       ),
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //
                    //               // ElevatedButton(
                    //               //   onPressed: () {
                    //               //  addtocart(
                    //               //      data['name'],
                    //               //      data['price'],
                    //               //      data['description'],
                    //               //      data["color"],
                    //               //      data['image']);
                    //               //   },
                    //               //   child: Text("Add to cart"),
                    //               // ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                  },
                ),
              ),

                // child: Row(
              //    // children: [
              //       Card(
              //         child: Padding(
              //           padding: const EdgeInsets.all(16.0),
              //           child: Column(
              //             children: [
              //               Image.asset("assets/item/toy.webp", height: 120,),
              //               Text("Toy"),
              //               Text("Rs. 650"),
              //               ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
              //             ],
              //           ),
              //         ),
              //       ),
              //      Card(
              //          child: Padding(
              //            padding: const EdgeInsets.all(16.0),
              //            child: Column(
              //              children: [
              //                Image.asset("assets/item/pen.webp", height: 120,),
              //                Text("Pen"),
              //                Text("Rs. 250"),
              //                ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
              //              ],
              //            ),
              //         ),
              //        ),
              //       Card(
              //         child: Padding(
              //           padding: const EdgeInsets.all(16.0),
              //           child: Column(
              //             children: [
              //               Image.asset("assets/item/pencil.png", height: 120,),
              //               Text("Pencil"),
              //               Text("Rs. 50"),
              //               ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
              //             ],
              //           ),
              //         ),
              //       ),
              //       Card(
              //         child: Padding(
              //           padding: const EdgeInsets.all(16.0),
              //           child: Column(
              //             children: [
              //               Image.asset("assets/item/note.webp", height: 120,),
              //               Text("Notebook"),
              //               Text("Rs. 500"),
              //               ElevatedButton(onPressed: (){}, child: Text("Add to cart"))
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],),
              // ),
              Text('Best Deal',style:TextStyle(
                  fontSize: 30,fontWeight: FontWeight.bold,color: Colors.blue)),
              Container(
                height: 350,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Best').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    // return GridView.builder(
                    //   padding: const EdgeInsets.all(10),
                    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: 2,
                    //     mainAxisSpacing: 10,
                    //     crossAxisSpacing: 10,
                    //     childAspectRatio: 0.7,
                    //   ),
                    //   itemCount: docs.length,
                    //   itemBuilder: (context, index) {
                    //     final data = docs[index].data() as Map<String, dynamic>;
                    //     return Container(
                    //       color: Colors.white,
                    //       child: GestureDetector(
                    //         onTap: () {
                    //           // Navigator.push(context, MaterialPageRoute(builder: (context)=>Productdetailpage(
                    //           //     data['name'],data['description'],data['price'],data['image']
                    //           //
                    //           // )));
                    //         },
                    //         child: Card(
                    //           elevation: 4,
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(12)),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.stretch,
                    //             children: [
                    //               Expanded(
                    //                 child: data['image'] != null && data['image'] != ""
                    //                     ? Image.memory(
                    //                   base64Decode(data['image']),
                    //                   fit: BoxFit.cover,
                    //                 )
                    //                     : const Icon(Icons.image, size: 80),
                    //               ),
                    //               Container(
                    //                 color: Colors.white38,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     // Text(data['name'] ?? "No Name",
                    //                     //     style: const TextStyle(
                    //                     //         fontWeight: FontWeight.bold)),
                    //                     Text("Rs .${data['Price'] ?? 'N/A'}",style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.deepOrange,
                    //                     ),),
                    //                     Container(
                    //                       padding: const EdgeInsets.symmetric(
                    //                           horizontal: 3, vertical: 1),
                    //                       decoration: BoxDecoration(
                    //                         color: Colors.deepOrange,
                    //                         borderRadius: BorderRadius.circular(6),
                    //                       ),
                    //                       child: Text("-80%",
                    //                         style: const TextStyle(
                    //                           color: Colors.white,
                    //                           fontSize: 12,
                    //                         ),
                    //                       ),
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //
                    //               // ElevatedButton(
                    //               //   onPressed: () {
                    //               //  addtocart(
                    //               //      data['name'],
                    //               //      data['price'],
                    //               //      data['description'],
                    //               //      data["color"],
                    //               //      data['image']);
                    //               //   },
                    //               //   child: Text("Add to cart"),
                    //               // ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // );
                    return SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () {
                                // Open product detail here
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: data['image'] != null && data['image'] != ""
                                          ? ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.memory(
                                          base64Decode(data['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : const Icon(Icons.image, size: 80),
                                    ),
                                    Container(
                                      color: Colors.white38,
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(data["Name"] ?? "No Name"),
                                          Text("Rs. ${data['Price'] ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            // child: const Text(
                                            //   "-80%",
                                            //   style: TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: 12,
                                            //   ),
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton(
                                        onPressed: (){
                                          addToCart(data);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${data['Name']} added to cart')),);

                                        },
                                        child: Text("Add to Cart")),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
             //  SingleChildScrollView(scrollDirection: Axis.horizontal,
             //    child: Row(
             //     children: [
             //      //  Image.asset('assets/item.jpg',height: 100),
             //      //  SizedBox(width: 30,),
             //      //  Image.asset('assets/item2.jpg',height: 100),
             //      //  SizedBox(width: 30,),
             //      //  Image.asset('assets/item2.jpg',height: 100),
             //      //  SizedBox(width: 30,),
             //      //  Image.asset('assets/item2.jpg',height: 100),
             //
             //
             //      ],),
             // ),
              SizedBox(height: 100,),
              Text("Categories",style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent
              ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Card(child:
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Image.asset("assets/item/men.jpeg",height: 120,),
                            ElevatedButton(onPressed: (){Navigator.push(
                                context, MaterialPageRoute(builder: (context) => Men()),
                            );}, child: Text("Men Section"))
                          ],
                        ),
                      ),),
                    Card(child:
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.asset("assets/item/women.webp",height: 120,),
                          ElevatedButton(onPressed: (){Navigator.push(
                              context, MaterialPageRoute(builder: (context)=>Women()),);
                            }, child: Text("Women Section"))
                        ],
                      ),
                    ),),
                    Card(child:
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.asset("assets/item/children.jpg",height: 120,),
                          ElevatedButton(onPressed: (){Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => kids()),
                          );}, child: Text("Children Section"))
                        ],
                      ),
                    ),),
                    Card(child:
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Image.asset("assets/item/babies.jpg",height: 120,),
                          ElevatedButton(onPressed: (){Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Baby()),
                          );}, child: Text("Babies Section"))
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
               // ElevatedButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context) => test()),);}, child: Text("Back")),
              ),
              SizedBox(height: 100),
              ElevatedButton(onPressed:()
                  async{
                    await FirebaseAuth.instance.signOut();
                    Fluttertoast.showToast(
                      msg: "Logged out successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pushReplacement(
                       context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );},
                  child: Text("Log out")
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.orange,

    );
  }
}