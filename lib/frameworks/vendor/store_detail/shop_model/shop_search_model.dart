import 'package:easy_debounce/easy_debounce.dart';
import '../../../../models/entities/product.dart';

import 'base_shop_model.dart';

class ShopSearchModel extends BaseShopModel with ShopModel {
  final _storeId;
  ShopSearchModel(this._storeId) {
    updateStateWithoutRebuild(ShopModelState.loaded);
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;

  @override
  Future<List<Product>> getProducts() async {
    updateState(ShopModelState.loading);
    setPage(1);
    final list = await services.api.getProductsByStore(
        storeId: _storeId,
        page: page,
        perPage: perPage,
        searchTerm: _searchTerm);
    if (list!.isNotEmpty) {
      setProducts(list);
    }
    updateState(ShopModelState.loaded);
    return list;
  }

  @override
  Future<List<Product>> loadProducts() async {
    setPage(page + 1);
    final list = await services.api.getProductsByStore(
        storeId: _storeId,
        page: page,
        perPage: perPage,
        searchTerm: _searchTerm);
    if (list!.isNotEmpty) {
      setProducts([...products, ...list]);
    }
    updateState(ShopModelState.loaded);
    return list;
  }

  void search(String val) {
    _searchTerm = val;
    products.clear();
    EasyDebounce.cancel('shopsearchmodel');
    if (_searchTerm.trim().isEmpty || _searchTerm.trim().length < 3) {
      updateState(ShopModelState.loaded);
      return;
    }

    EasyDebounce.debounce(
        'shopsearchmodel', const Duration(milliseconds: 500), getProducts);
  }
}
