import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/helpers/screen_arguments.dart';
import '../providers/auth.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../constants.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    Constants().init(context);

    final deviceSize = Constants.kScreenSize;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            reverseTransitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(
              opacity: animation,
              child: const ProductDetailScreen(),
            ),
            settings:
                RouteSettings(arguments: ScreenArguments(product.id, false)),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(25),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(product.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      Provider.of<Product>(context, listen: false)
                          .toggleFavouriteStatus(
                              FirebaseAuth.instance.currentUser!.uid);
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //       content: const Text('item added to the cart'),
                      //       margin: const EdgeInsets.symmetric(vertical: 55.0),
                      //       behavior: SnackBarBehavior.floating,
                      //       duration: const Duration(seconds: 2),
                      //       action: SnackBarAction(
                      //         label: 'undo',
                      //         onPressed: () {
                      //           cart.removeSingleItem(product.id);
                      //         },
                      //       )),
                      // );
                      cart.addItem(product.id, product.title, product.price,
                          product.imageUrl);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(
                height: deviceSize!.height * 0.15,
                child: Hero(
                  tag: product.title,
                  child: FadeInImage(
                    placeholder:
                        const AssetImage('images/product-placeholder.png'),
                    image: NetworkImage(
                      product.imageUrl,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Center(
                child: Text(product.title),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Center(
                child: Text('Rs.' + product.price.round().toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
