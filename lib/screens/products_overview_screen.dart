import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/helpers/screen_arguments.dart';
import 'package:shopping_app/screens/product_detail_screen.dart';
import '../providers/auth.dart';
import '../providers/products.dart';
import '../constants.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';
import '../widgets/products_grid.dart';
import 'orders_screen.dart';

enum FilterOptions { favs, all }

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  static String id = 'ProductOverviewScreen';

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.notification!.title}");
}

Future<void> _configureFirebaseListeners() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.instance.subscribeToTopic('messaging');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.title}');
      }
    });
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(
        'A new onMessageOpenedApp event was published! ${message.notification!.title}');
  });
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  String _buttonText = 'Favourite';
  bool _showOnlyFavourite = false;
  bool _isInit = true;
  late bool _isLoading;

  @override
  void initState() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        setState(() {
          _isLoading = true;
        });
        _configureFirebaseListeners();
        Provider.of<Products>(context).fetchAndSetProducts().then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Constants().init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarCustom(),
            Container(
              height: Constants.kScreenSize!.height * 0.82,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: Constants.kScreenSize!.width * 0.42,
                          height: Constants.kScreenSize!.height * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_buttonText == 'Favourite') {
                                  _buttonText = 'All';
                                  _showOnlyFavourite = true;
                                } else {
                                  _buttonText = 'Favourite';
                                  _showOnlyFavourite = false;
                                }
                              });
                            },
                            child: Text(_buttonText),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 5.0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Constants.kScreenSize!.width * 0.42,
                          height: Constants.kScreenSize!.height * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, OrdersScreen.id);
                            },
                            child: const Text('Orders'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              elevation: 5.0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ProductsGrid(isFavourite: _showOnlyFavourite),
                  )
                ],
              ),
            ),
            const Expanded(
              child: BottomCart(),
            )
          ],
        ),
      ),
    );
  }
}

class BottomCart extends StatefulWidget {
  const BottomCart({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomCart> createState() => _BottomCartState();
}

class _BottomCartState extends State<BottomCart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              'Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, _) => Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: cartData.items.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Hero(
                    tag: '${cartData.items.values.toList()[i].title}_cartTag',
                    child: Center(
                      child: Container(
                        width: 50.0,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: FocusedMenuHolder(
                            menuWidth: 120,
                            blurSize: 3,
                            child: Image.network(
                              cartData.items.values.toList()[i].imageUrl,
                              fit: BoxFit.scaleDown,
                            ),
                            onPressed: () {
                              loadProduct(context, cartData, i);
                            },
                            menuItems: [
                              FocusedMenuItem(
                                  title: const Text('Remove'),
                                  trailingIcon: const Icon(Icons.delete),
                                  onPressed: () {
                                    var cartProduct = Provider.of<Products>(
                                            context,
                                            listen: false)
                                        .items
                                        .firstWhere((element) =>
                                            element.title ==
                                            cartData.items.values
                                                .toList()[i]
                                                .title);
                                    Provider.of<Cart>(context, listen: false)
                                        .removeItem(cartProduct.id);
                                  })
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Consumer<Cart>(
            builder: (_, cartData, _ch) => Badge(
              badgeContent: Text(cartData.itemsCount.toString()),
              child: _ch,
              alignment: Alignment.topRight,
              position: const BadgePosition(end: 0),
              badgeColor: Colors.amber,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.id);
              },
              icon: const Icon(
                Icons.navigate_next_outlined,
                color: Colors.white,
                size: 40.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loadProduct(BuildContext context, Cart cartData, int i) {
    final productId = Provider.of<Products>(context, listen: false)
        .items
        .firstWhere((element) =>
            element.title == cartData.items.values.toList()[i].title)
        .id;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const ProductDetailScreen(),
        ),
        settings: RouteSettings(arguments: ScreenArguments(productId, true)),
      ),
    );
  }
}

class AppBarCustom extends StatelessWidget {
  const AppBarCustom({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 6, 14, 0),
      height: 60, //Constants.kScreenSize!.height * 0.075,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Catalog',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              size: 30.0,
            ),
          ),
          IconButton(
            onPressed: () async {
              await Provider.of<Auth>(context, listen: false).signOut();
            },
            icon: const Icon(
              Icons.exit_to_app_rounded,
              size: 30.0,
            ),
          ),
        ],
      ),
    );
  }
}
