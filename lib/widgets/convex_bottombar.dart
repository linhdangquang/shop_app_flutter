import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class ConVexBottomBar extends StatelessWidget {
  const ConVexBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.shopping_cart, title: 'Cart'),
          TabItem(icon: Icons.payment_rounded, title: 'Orders'),
          TabItem(icon: Icons.settings, title: 'Settings'),
        ],
        elevation: 5,
        top: -20,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushNamed('/cart');
          }
          if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/orders');
          }
        },
        gradient: const LinearGradient(
          colors: [
            Colors.red,
            Colors.green,
            Colors.pink,
            Colors.blue,
            Colors.purple,
          ],
        ),
        style: TabStyle.flip);
  }
}
