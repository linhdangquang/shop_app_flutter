import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;
  // final _isInit = true;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() async {
  //   if (_isInit) {
  //     try {
  //       setState(() => _isLoading = true);
  //       await Provider.of<Products>(context, listen: false)
  //           .fetchAndSetProducts();
  //     } catch (e) {
  //       print(e);
  //     } finally {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    // final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            tooltip: 'Filter Products',
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: FilterOptions.Favorites,
                  child: Text('Only Favorites')),
              const PopupMenuItem(
                  value: FilterOptions.All, child: Text('Show All')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
              builder: (_, cart, wgChild) => Badge(
                    value: cart.itemCount.toString(),
                    child: wgChild!,
                  ),
              child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CartScreen.routeName);
                  },
                  icon: const Icon(Icons.shopping_cart)))
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: LinearProgressIndicator(
                minHeight: 10,
              ),
            )
          : ProductsGrid(
              showOnlyFavorites: _showOnlyFavorites,
            ),
    );
  }
}
