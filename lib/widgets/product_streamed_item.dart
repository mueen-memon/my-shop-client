import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';

import '../constants.dart';

class ProductStreamedItem extends StatefulWidget {
  ProductStreamedItem({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  State<ProductStreamedItem> createState() => _ProductStreamedItemState();
}

class _ProductStreamedItemState extends State<ProductStreamedItem> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final _auth = FirebaseAuth.instance;

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
            settings: RouteSettings(arguments: widget.product.id),
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
                    icon: Icon(widget.product.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      setState(() {
                        String userId = _auth.currentUser!.uid;
                        widget.product.toggleFavouriteStatus(userId);
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      cart.addItem(widget.product.id, widget.product.title,
                          widget.product.price, widget.product.imageUrl);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(
                height: deviceSize!.height * 0.15,
                child: Hero(
                  tag: widget.product.title,
                  child: FadeInImage(
                    placeholder:
                        const AssetImage('images/product-placeholder.png'),
                    image: NetworkImage(
                      widget.product.imageUrl,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Center(
                child: Text(widget.product.title),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Center(
                child: Text('Rs.' + widget.product.price.round().toString(),
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
