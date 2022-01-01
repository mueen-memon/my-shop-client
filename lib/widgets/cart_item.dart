import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

class CartItem extends StatelessWidget {
  const CartItem({
    Key? key,
    required this.title,
    required this.price,
    required this.quantity,
    required this.id,
    required this.productId,
    required this.imageUrl,
  }) : super(key: key);

  final String productId;
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    Constants().init(context);
    final cart = Provider.of<Cart>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Dismissible(
        key: ValueKey(id),
        background: Container(
          color: Theme.of(context).errorColor,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 40.0,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeItem(productId);
        },
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    content:
                        const Text('Are you sure you want to delete this item'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ));
        },
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 3.0,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xffF8F8F8),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  // Image Container
                  width: 80.0,
                  height: 110.0,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xffE9F4F9),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    child: Image.network(
                        Provider.of<Products>(context, listen: false)
                            .productImage(productId),
                        fit: BoxFit.contain),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'Rs. ' + price.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rs. ${(price * quantity).toInt().toString()}',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: 100.0,
                                  height: 50.0,
                                  // margin: EdgeInsets.only(bottom: 1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          onPressed: () {
                                            cart.removeSingleItem(productId);
                                          },
                                          icon: const Icon(
                                            Icons.remove,
                                            color: Colors.orange,
                                            size: 26.0,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          onPressed: () {
                                            cart.addItem(productId, title,
                                                price, imageUrl);
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                            size: 26.0,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
