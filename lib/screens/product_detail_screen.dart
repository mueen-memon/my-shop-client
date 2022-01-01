import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/helpers/screen_arguments.dart';
import '../constants.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/products.dart';

var cartTag = '';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  static String id = 'ProductDetailScreen';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var init = true;

  @override
  Widget build(BuildContext context) {
    Constants().init(context);

    ScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    late String producID = args.productId;

    if (init) {
      if (args.isCart) {
        cartTag = '_cartTag';
      } else {
        cartTag = '';
      }
      init = false;
    }

    var loadedProduct = Provider.of<Products>(
      context,
    ).findByID(producID);

    return WillPopScope(
      onWillPop: () async {
        if (args.isCart) {
          cartTag = '_cartTag';
        } else {
          cartTag = '';
        }
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffE9F4F9),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(2, 4, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        size: 40.0,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          loadedProduct.toggleFavouriteStatus(
                            FirebaseAuth.instance.currentUser!.uid,
                          );
                        });
                      },
                      icon: Icon(
                        loadedProduct.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 30.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                height: Constants.kScreenSize!.height * 0.35,
                width: double.infinity,
                child: Hero(
                  tag: loadedProduct.title + cartTag,
                  child: Image.network(
                    loadedProduct.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    40.0,
                    40.0,
                    40.0,
                    15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loadedProduct.title,
                            style: Constants.kTitleTextStyle(),
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          RatingBar.builder(
                              allowHalfRating: true,
                              initialRating: 4.5,
                              minRating: 1,
                              itemCount: 5,
                              itemSize: 25,
                              unratedColor: Colors.amber[100],
                              itemBuilder: (ctx, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              onRatingUpdate: (rating) {}),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '0 Reviews',
                            style: Constants.kDescriptionTextStyle(),
                          ),
                        ],
                      ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      Text(
                        loadedProduct.description,
                        style: Constants.kDescriptionTextStyle(),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 80.0,
                        child: ElevatedButton(
                          onPressed: () {
                            loadedProduct = Provider.of<Products>(
                              context,
                              listen: false,
                            ).findByID(producID);
                            Provider.of<Cart>(context, listen: false).addItem(
                                loadedProduct.id,
                                loadedProduct.title,
                                loadedProduct.price,
                                loadedProduct.imageUrl);

                            setState(() {
                              cartTag = '_cartTag';
                            });

                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Constants.kSecondaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 12.0,
                              right: 1.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Constants.kScreenSize!.width * 0.33,
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Rs. ' +
                                          loadedProduct.price
                                              .toInt()
                                              .toString(),
                                      style: const TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.shopping_cart,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            'Add to Cart',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
