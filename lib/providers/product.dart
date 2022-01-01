import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  late final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavaValue(bool status) {
    isFavourite = status;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String userId) async {
    isFavourite = !isFavourite;
    print('changed to: $isFavourite of product: $title');
    final userFavourites =
        FirebaseFirestore.instance.collection('userFavourites');
    notifyListeners();
    var _oldStatus = isFavourite;
    try {
      await userFavourites.doc(userId).set(
        {id: isFavourite},
        SetOptions(merge: true),
      );
    } catch (e) {
      print('error here: ' + e.toString());
      _setFavaValue(_oldStatus);
    }
    notifyListeners();
  }
}
