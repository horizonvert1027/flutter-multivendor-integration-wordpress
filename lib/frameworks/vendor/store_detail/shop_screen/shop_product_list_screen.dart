import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/entities/product.dart';
import '../shop_model/export.dart';
import '../shop_widget/shop_product_item.dart';

enum ShopType { category, onSale, latest, popular }

class ShopProductListScreen extends StatefulWidget {
  final ShopType? type;
  final String? name;
  final BuildContext? ctx;
  const ShopProductListScreen({Key? key, this.type, this.name, this.ctx})
      : super(key: key);
  const ShopProductListScreen.category(
      {Key? key, this.type = ShopType.category, this.name, required this.ctx})
      : super(key: key);
  const ShopProductListScreen.onSale(
      {Key? key, this.type = ShopType.onSale, this.name, required this.ctx})
      : super(key: key);
  const ShopProductListScreen.latest(
      {Key? key, this.type = ShopType.latest, this.name, required this.ctx})
      : super(key: key);
  const ShopProductListScreen.popular(
      {Key? key, this.type = ShopType.popular, this.name, required this.ctx})
      : super(key: key);

  @override
  State<ShopProductListScreen> createState() => _ShopProductListScreenState();
}

class _ShopProductListScreenState extends State<ShopProductListScreen> {
  final _controller = RefreshController();
  Future<void> _onLoading(model) async {
    final list = await model.loadProducts();

    if (list.isEmpty) {
      _controller.loadNoData();
      return;
    }
    _controller.loadComplete();
  }

  Widget _buildProductItem(Product fProduct, {Product? sProduct}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: 210,
      width: size.width ~/ 2 - 10,
      child: Row(
        children: [
          Expanded(child: ProductShopItem(product: fProduct)),
          if (sProduct != null)
            Expanded(child: ProductShopItem(product: sProduct)),
          if (sProduct == null) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProductLoadingItem() {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      width: size.width ~/ 2 - 10,
      child: Row(
        children: const [
          Expanded(
            child: ProductShopItem.loading(),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: ProductShopItem.loading(),
          ),
        ],
      ),
    );
  }

  Widget _listProductWidget(model) {
    final theme = Theme.of(context);
    const col = 2;
    final isEmpty =
        model.products.isEmpty && model.state == ShopModelState.loaded;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(widget.name ?? ''),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: SmartRefresher(
          controller: _controller,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () => _onLoading(model),
          child: isEmpty
              ? Center(child: Text(S.of(context).noData))
              : ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    if (model.state == ShopModelState.loading) {
                      return _buildProductLoadingItem();
                    }
                    if (((model.products.length - 1) == index * col) &&
                        (model.products.length % col) != 0) {
                      return _buildProductItem(
                        model.products[index * col],
                      );
                    }
                    return _buildProductItem(model.products[index * col],
                        sProduct: model.products[(index * col) + 1]);
                  },
                  itemCount: model.state == ShopModelState.loading
                      ? 6
                      : (model.products.length / 2).round(),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var model;

    switch (widget.type) {
      case ShopType.category:
        model = Provider.of<ShopCategoryModel>(widget.ctx!, listen: false);
        return ChangeNotifierProvider<ShopCategoryModel>.value(
            value: model,
            child: Consumer<ShopCategoryModel>(
                builder: (_, model, __) => _listProductWidget(model)));
      case ShopType.latest:
        model = Provider.of<ShopNewModel>(widget.ctx!, listen: false);
        return ChangeNotifierProvider<ShopNewModel>.value(
            value: model,
            child: Consumer<ShopNewModel>(
                builder: (_, model, __) => _listProductWidget(model)));
      case ShopType.onSale:
        model = Provider.of<ShopOnSaleModel>(widget.ctx!, listen: false);
        return ChangeNotifierProvider<ShopOnSaleModel>.value(
            value: model,
            child: Consumer<ShopOnSaleModel>(
                builder: (_, model, __) => _listProductWidget(model)));
      default:
        model = Provider.of<ShopPopularModel>(widget.ctx!, listen: false);
        return ChangeNotifierProvider<ShopPopularModel>.value(
            value: model,
            child: Consumer<ShopPopularModel>(
                builder: (_, model, __) => _listProductWidget(model)));
    }
  }
}
