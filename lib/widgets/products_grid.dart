import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

import 'product_item.dart';
import 'product_streamed_item.dart';

class ProductsGrid extends StatelessWidget {
  ProductsGrid({Key? key, required this.isFavourite}) : super(key: key);
  final bool isFavourite;

  @override
  Widget build(BuildContext context) {
    var productsData = Provider.of<Products>(context);
    var products = isFavourite ? productsData.favourites : productsData.items;
    final documentsStream =
        FirebaseFirestore.instance.collection('products').snapshots();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: documentsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("An error has occured.");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData) {
                return const Text("There is no product available");
              }
            }
            if (snapshot.hasData) {
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24.0, 18, 24.0, 24.0),
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  return ChangeNotifierProvider.value(
                    value: products[i],
                    child: const ProductItem(),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 20.0,
                ),
              );
            }

            return Text('Loading....');
          }),
    );
  }
}
