import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);

  static const routeName = '/user_products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Products'),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName),
                icon: const Icon(Icons.add))
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: ((context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: ((context, productsData, _) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListView.builder(
                                itemBuilder: ((_, index) => Column(
                                      children: [
                                        UserProductItem(
                                            id: productsData.items[index].id,
                                            title:
                                                productsData.items[index].title,
                                            imageUrl: productsData
                                                .items[index].imageUrl),
                                        const Divider(),
                                      ],
                                    )),
                                itemCount: productsData.items.length),
                          )),
                    )))));
  }
}
