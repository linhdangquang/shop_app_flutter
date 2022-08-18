import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  static const routeName = '/cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .titleMedium
                                    ?.color),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        OrderButton(cart: cart)
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: ((context, index) {
                    var items = cart.items.values.toList();
                    return CartItem(
                        id: items[index].id,
                        productId: cart.items.keys.toList()[index],
                        price: items[index].price,
                        quantity: items[index].quantity,
                        title: items[index].title);
                  }),
                  itemCount: cart.items.length,
                ))
              ],
            ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cart.items.values.toList(), widget.cart.totalAmount);
                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
                Fluttertoast.showToast(
                    msg: 'Order placed successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
        child: _isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
              )
            : const Text('ORDER NOW',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
  }
}
