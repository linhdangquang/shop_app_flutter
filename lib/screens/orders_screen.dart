import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/order_item.dart' as OrderItemWidget;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future? _ordersFuture;

  final int _count = 0;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return const Center(
                  child: Text('An error occurred!'),
                );
              } else {
                return Consumer<Orders>(
                    builder: (ctx, ordersData, child) => ListView.builder(
                          itemCount: ordersData.orders.length,
                          itemBuilder: (ctx, index) =>
                              OrderItemWidget.OrderItem(
                            order: ordersData.orders[index],
                          ),
                        )
                    // ElevatedButton(
                    //     onPressed: () {
                    //       setState(() {
                    //         _count++;
                    //       });
                    //     },
                    //     child: Text('$_count')));
                    );
              }
            }
          }),
    );
  }
}
