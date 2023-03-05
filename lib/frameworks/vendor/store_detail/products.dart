import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart' show Product;
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../screens/base_screen.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';

class ProductList extends StatefulWidget {
  final int? storeId;

  const ProductList({this.storeId});

  @override
  BaseScreen<ProductList> createState() => _ProductListState();
}

class _ProductListState extends BaseScreen<ProductList> {
  List<Product>? products;
  int page = 1;
  bool isFetching = false;
  bool isEnd = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Product> emptyList = [
    Product.empty('1'),
    Product.empty('2'),
    Product.empty('3'),
    Product.empty('4'),
    Product.empty('5'),
    Product.empty('6')
  ];

  @override
  void afterFirstLayout(BuildContext context) async {
    getProducts();
  }

  void getProducts() async {
    try {
      if (isFetching) return;
      setState(() {
        isFetching = true;
        products = [];
        isEnd = false;
      });
      final list = await Services()
          .api
          .getProductsByStore(storeId: widget.storeId, page: 1)!;
      setState(() {
        isFetching = false;
        products = list;
      });
    } catch (e) {
      setState(() {
        isFetching = false;
        products = [];
      });
      rethrow;
    }
    _refreshController.refreshCompleted();
  }

  void loadMore() async {
    try {
      if (isFetching) return;
      setState(() {
        isFetching = true;
      });
      final list = await Services()
          .api
          .getProductsByStore(storeId: widget.storeId, page: page + 1)!;
      if (list.length < 2) {
        setState(() {
          isEnd = true;
        });
      }
      setState(() {
        isFetching = false;
        products = [...products!, ...list];
        page = page + 1;
      });
    } catch (e) {
      setState(() {
        isFetching = false;
        products = [];
      });
      rethrow;
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final productsList = (products == null || products!.isEmpty) && isFetching
        ? emptyList
        : products;

    if (productsList == null || productsList.isEmpty) {
      return Center(
          child: Text(S.of(context).noProduct,
              style: const TextStyle(color: Colors.black)));
    }

    return LayoutBuilder(
      builder: (context, contraints) {
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
          child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: !isEnd,
            controller: _refreshController,
            onRefresh: getProducts,
            onLoading: loadMore,
            child: productsList.isNotEmpty
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                    ),
                    cacheExtent: 10000.0,
                    itemCount: productsList.length,
                    itemBuilder: (context, i) {
                      return SizedBox(
                        width: 100,
                        child: ProductCard(
                          item: productsList[i],
                          width: contraints.maxWidth / 2,
                          config: ProductConfig.empty()..showHeart = true,
                          // tablet: widget.width / screenSize.height > 1.2,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(S.of(context).myProductsEmpty),
                  ),
          ),
        );
      },
    );
  }
}
