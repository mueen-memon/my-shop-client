import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/providers/cart.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' as ord;

class OrdersScreen extends StatelessWidget {
  static String id = 'OrderScreen';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Orders'),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(userId)
            .collection('user_orders')
            .snapshots(),
        builder: (ctx, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    DocumentSnapshot orderData = snapshot.data!.docs[index];

                    return OrderItem(
                        order: ord.OrderItem(
                      orderId: orderData.id,
                      amount: orderData['amount'],
                      orderStatus: orderData['order status'],
                      date: DateTime.parse(
                        orderData['date'],
                      ),
                      products: (orderData['products'] as List<dynamic>)
                          .map(
                            (item) => CartItem(
                              id: item['id'],
                              title: item['title'],
                              quantity: item['quantity'],
                              price: item['price'],
                              imageUrl: '',
                            ),
                          )
                          .toList(),
                    ));
                  },
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
