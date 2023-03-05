import '../../../../data/boxes.dart';
import '../../../../models/entities/index.dart';
import '../../../../services/services.dart';
import 'base_shop_model.dart';

class ShopCategoryModel extends BaseShopModel with ShopModel {
  final _services = Services();
  List<Category> _categories = [];

  List<Category> get categories => _categories;
  final List<Category> _storedCategires = [];

  /// If users need sub-categories in the future, these will be helpful.
  /// Sub-categories is not implemented right now.
  // final Map<String?, Map<String, dynamic>> _categoriesMap = {};
  // Map<String?, Map<String, dynamic>> get categories => _categoriesMap;
  String key = '';
  final _storeId;

  int _catId = -1;
  final lang;

  bool _isGettingCategories = true;

  bool get isGettingCategories => _isGettingCategories;

  ShopCategoryModel(this._storeId, {this.lang = 'en'}) {
    key = 'shop-$_storeId-categories-$lang';
    _getLocalCategories();
    getCategories(1);
  }

  void setCatId(String id) {
    _catId = int.parse(id);
  }

  @override
  Future<List<Product>> getProducts() async {
    updateState(ShopModelState.loading);
    setPage(1);
    final list = await services.api.getProductsByStore(
        storeId: _storeId, page: page, perPage: perPage, catId: _catId);

    setProducts(list!);

    updateState(ShopModelState.loaded);
    return list;
  }

  @override
  Future<List<Product>> loadProducts() async {
    setPage(page + 1);
    final list = await services.api.getProductsByStore(
        storeId: _storeId, page: page, perPage: perPage, catId: _catId);
    if (list!.isNotEmpty) {
      setProducts([...products, ...list]);
    }
    updateState(ShopModelState.loaded);
    return list;
  }

  void getCategories(int page) {
    _services.api
        .getCategoriesByPage(
            page: page, limit: 100, storeId: _storeId, lang: lang)
        .then((list) {
      if (list.isNotEmpty) {
        _storedCategires.addAll(list);
        getCategories(page + 1);
      } else {
        _categories = _storedCategires;
        _isGettingCategories = false;

        updateState(ShopModelState.loaded);
        _saveLocalCategories();
        return;
      }
    });
  }

  // void _saveCategories(String categoryId, String name) {
  //   if (_categoriesMap[categoryId] == null) {
  //     _categoriesMap[categoryId] = {};
  //     _categoriesMap[categoryId]!['name'] = '';
  //     _categoriesMap[categoryId]!['categories'] = [];
  //   }
  //   var tmpListCat = [];
  //   for (var cat in _categories) {
  //     if (cat.parent == categoryId) {
  //       tmpListCat.add(cat);
  //     }
  //   }
  //   _categoriesMap[categoryId]!['name'] = name;
  //   _categoriesMap[categoryId]!['categories'] = tmpListCat;
  //   if (tmpListCat.isNotEmpty) {
  //     for (var category in tmpListCat) {
  //       _saveCategories(category.id, category.name ?? '');
  //     }
  //   }
  // }

  void _saveLocalCategories() {
    final data = _categories.map((e) => e.toJson()).toList();
    CacheBox().setShopCategoryCache(key, data);
  }

  void _getLocalCategories() async {
    final data = CacheBox().getShopCategoryCache(key);
    if (data != null && data.isNotEmpty) {
      for (var category in data) {
        _categories.add(Category.fromJson(category));
      }
      // _saveCategories('0', '');
      // _categories.clear();
      _isGettingCategories = false;
      notifyListeners();
    }
  }
}
