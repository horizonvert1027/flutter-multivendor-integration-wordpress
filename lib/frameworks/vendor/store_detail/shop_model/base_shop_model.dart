import 'package:flutter/material.dart';
import '../../../../models/entities/product.dart';
import '../../../../services/services.dart';

abstract class BaseShopModel extends ChangeNotifier {
  Future<List<Product>> getProducts() async => [];

  Future<List<Product>> loadProducts() async => [];
}

enum ShopModelState { loading, loaded }

mixin ShopModel on ChangeNotifier {
  List<Product> _products = [];
  List<Product> get products => _products;
  ShopModelState _state = ShopModelState.loading;
  ShopModelState get state => _state;
  int _page = 1;
  int get page => _page;
  final _perPage = 10;
  int get perPage => _perPage;
  final _services = Services();
  Services get services => _services;
  bool _isDisposed = false;

  void updateState(state) {
    if (!_isDisposed) {
      _state = state;
      notifyListeners();
    }
  }

  void updateStateWithoutRebuild(state) {
    _state = state;
  }

  void setProducts(List<Product> products) {
    _products = products;
  }

  void setPage(int page) {
    _page = page;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
