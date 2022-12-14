import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem(
      {Key? key, required this.id, required this.title, required this.imageUrl})
      : super(key: key);

  final String id;
  final String title;
  final String imageUrl;

  void _deleteProduct(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false).deleteProduct(id);
      Fluttertoast.showToast(
          msg: 'Product deleted',
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.white);
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred while deleting product.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EditProductScreen.routeName,
                  arguments: id,
                );
              },
              color: Theme.of(context).primaryColorDark,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
              onPressed: () {
                _deleteProduct(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
