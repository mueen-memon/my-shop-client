import 'dart:convert';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

enum OrderStatus { AwaitingConfirmation, confimed, dispatched, delievered }

class OrderItem {
  final String orderId;
  final double amount;
  final List<CartItem> products;
  final DateTime date;
  final String orderStatus;

  OrderItem({
    required this.orderId,
    required this.amount,
    required this.products,
    required this.date,
    required this.orderStatus,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  late String authToken;
  String userId = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getAuthInfo() async {
    userId = _auth.currentUser!.uid;
    authToken = await _auth.currentUser!.getIdToken();
  }

  Future<bool> initiateNotification(String title, String message) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAy62X9lk:APA91bFsUx5iJP7Pa4c8JZIoUefOlK_5tnxU2liXob29fIbxTSNVTj_sykMxxrDhuYpioLVOGaeTAK7-tt9KqxAbHmqVjRqMOFoM6-oa_RFZwKapRqS59zwgzon8iwPnUzA2Dq5m420j",
      };
      var request = {
        "notification": {
          "title": title,
          "text": message,
          "sound": "default",
          "color": "#990000",
        },
        "priority": "high",
        "to": "/topics/messaging",
      };

      var response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(request));
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    if (userId == '') await getAuthInfo();

    try {
      var orders = FirebaseFirestore.instance
          .collection('orders')
          .doc(userId)
          .collection('user_orders');

      final timeStamp = DateTime.now();
      final responce = await orders.add(
        {
          'date': timeStamp.toIso8601String(),
          'amount': total,
          'order status': EnumToString.convertToString(
              OrderStatus.AwaitingConfirmation,
              camelCase: true),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        },
      );

      await initiateNotification(
          'Order Recieved', 'A new order has been initiated');

      _orders.insert(
        0,
        OrderItem(
          orderId: responce.id,
          amount: total,
          products: cartProducts,
          date: timeStamp,
          orderStatus: 'Awaiting Confirmation',
        ),
      );

      notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> fetchAndSetOrders() async {
    if (userId == '') await getAuthInfo();

    _orders = [];

    var ordersData =
        FirebaseFirestore.instance.collection('users/$userId/user_orders');

    final responce = await ordersData.get();
    print('length ${responce.docs.length}');

    // if (responce.size == 'null') {
    //   return;
    // }

    final List<OrderItem> loadedOrders = [];
    try {
      final extractedData = responce.docs;
      print('items: ' + extractedData.length.toString() + ' $userId');

      extractedData.forEach((ordData) {
        print('here');
        print(ordersData.id);
        loadedOrders.add(
          OrderItem(
            orderId: ordersData.id,
            date: DateTime.parse(ordData['date']),
            amount: ordData['amount'],
            products: (ordData['products'] as List<dynamic>)
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
            orderStatus: ordData['order status'],
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      print('error $e');
      rethrow;
    }
  }
}
