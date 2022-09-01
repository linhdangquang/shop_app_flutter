import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeStr =
      await rootBundle.loadString('assets/theme/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson);

  runApp(MyApp(theme: theme as ThemeData));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.theme}) : super(key: key);
  final ThemeData theme;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (context, auth, previousProducts) => Products(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
            create: (context) => Products('', [], ''),
          ),
          ChangeNotifierProvider(create: (context) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders(authToken: '', userId: '', orders: []),
            update: (context, auth, previousOrders) => Orders(
                authToken: auth.token,
                orders: previousOrders == null ? [] : previousOrders.orders,
                userId: auth.userId),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) {
            return MaterialApp(
              title: 'Shop App',
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: auth.isAuth
                  ? const ProductOverviewScreen()
                  : FutureBuilder(
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SplashScreen();
                        } else {
                          return const AuthScreen();
                        }
                      }),
                      future: auth.tryAutoLogin(),
                    ),
              routes: {
                // ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => const CartScreen(),
                // OrdersScreen.routeName: (ctx) => const OrdersScreen(),
                UserProductsScreen.routeName: (ctx) =>
                    const UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => const EditProductScreen(),
                AuthScreen.routeName: (ctx) => const AuthScreen(),
              },
              onGenerateRoute: ((settings) {
                switch (settings.name) {
                  case OrdersScreen.routeName:
                    return PageTransition(
                        child: const OrdersScreen(),
                        type: PageTransitionType.rightToLeft,
                        settings: settings);
                  case ProductDetailScreen.routeName:
                    return PageTransition(
                        child: ProductDetailScreen(),
                        type: PageTransitionType.fade,
                        settings: settings);
                  default:
                    return MaterialPageRoute(
                      builder: (ctx) => const AuthScreen(),
                    );
                }
              }),
            );
          },
        ));
  }
}
