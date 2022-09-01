import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

const apiUrl = 'shop-app-flutter-a2d5b-default-rtdb.firebaseio.com';

class Products with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Product> _items = [];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;
  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://$apiUrl/products.json?auth=$authToken&$filterString');
    final favoriteUrl =
        Uri.https(apiUrl, '/userFavorites/$userId.json', {'auth': authToken});
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData.isEmpty) {
        return;
      }
      final favoritesRes = await http.get(favoriteUrl);
      final favoritesData = json.decode(favoritesRes.body);

      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          price: productData['price'],
          description: productData['description'],
          isFavorite:
              favoritesData == null ? false : favoritesData[productId] ?? false,
          imageUrl: productData['imageUrl'],
        ));
      });
      _items.clear();
      _items.addAll(loadedProducts);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.https(apiUrl, '/products.json', {'auth': authToken});
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
      return Future.value();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = Uri.https(apiUrl, '/products/$id.json', {'auth': authToken});
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      return;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(apiUrl, '/products/$id.json', {'auth': authToken});
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    dynamic existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}
