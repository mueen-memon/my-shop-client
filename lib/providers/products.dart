import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helpers/http_exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favourites {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findByID(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  bool getFavStatus(String productId) {
    return _items.firstWhere((element) => element.id == productId).isFavourite;
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final List<Product> loadedProducts = [];

      CollectionReference products = firestore.collection('products');
      var favourites = firestore
          .collection('userFavourites')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      var favouriteData = await favourites.get();

      final productsStream = products.snapshots();

      productsStream.listen((event) {
        event.docChanges.forEach((prod) {
          var prodData = prod.doc;
          if (prod.type == DocumentChangeType.added) {
            loadedProducts.add(
              Product(
                  id: prodData.id,
                  title: prodData['title'],
                  description: prodData['description'],
                  price: prodData['price'],
                  isFavourite: favouriteData.exists == false
                      ? false
                      : favouriteData.data()!.containsKey(prodData.id)
                          ? favouriteData[prodData.id]
                          : false,
                  imageUrl: prodData['imageUrl']),
            );

            notifyListeners();
          } else if (prod.type == DocumentChangeType.modified) {
            var changedProd =
                _items.firstWhere((element) => element.id == prodData.id);
            var index = _items.indexOf(changedProd);

            _items[index] = Product(
                id: prodData.id,
                title: prodData['title'],
                description: prodData['description'],
                price: prodData['price'],
                isFavourite: favouriteData.exists == false
                    ? false
                    : favouriteData.data()!.containsKey(prodData.id)
                        ? favouriteData[prodData.id]
                        : false,
                imageUrl: prodData['imageUrl']);

            notifyListeners();
          } else if (prod.type == DocumentChangeType.removed) {
            var changedProd =
                _items.firstWhere((element) => element.id == prodData.id);
            _items.remove(changedProd);

            notifyListeners();
          }
        });
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      print('error: $e');
    }
  }

  String productImage(String id) {
    return _items.firstWhere((element) => element.id == id).imageUrl;
  }
}
