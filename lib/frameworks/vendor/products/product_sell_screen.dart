import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants.dart';
import '../../../common/tools/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/cart/cart_base.dart';
import '../../../models/index.dart'
    show Product, ProductModel, RecentModel, UserModel;
import '../../../models/product_wish_list_model.dart';
import '../../../modules/dynamic_layout/config/product_config.dart';
import '../../../routes/flux_navigate.dart';
import '../../../services/index.dart';
import '../../../widgets/common/loading_body.dart';
import '../../../widgets/product/product_card_view.dart';

class ProductSellScreen extends StatefulWidget {
  @override
  State<ProductSellScreen> createState() => _StateProductSell();
}

class _StateProductSell extends State<ProductSellScreen> {
  final Services _services = Services();
  List<Product> _products = [];

  bool isLoading = true;
  bool loadMore = true;
  int page = 1;
  String? errMsg;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showButton = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleShowButton);
    Future.delayed(Duration.zero, () {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _services.api
          .getOwnProducts(userModel.user!.cookie, page: 1)!
          .then((onValue) {
        setState(() {
          if (onValue.isNotEmpty) {
            _products = onValue;
          }
          isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          errMsg = e.toString();
        });
      });
    });
  }

  void _handleShowButton() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      _showButton.value = false;
    } else if (direction == ScrollDirection.forward) {
      _showButton.value = true;
    }
  }

  Future createProduct() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await FluxNavigate.pushNamed(RouteList.createProduct);
    setState(() {
      isLoading = true;
    });

    final product =
        await _services.api.getOwnProducts(userModel.user!.cookie, page: 1)!;
    setState(() {
      _products = product;
      isLoading = false;
    });
  }

  void _onRefresh() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _services.api
        .getOwnProducts(userModel.user!.cookie, page: 1)!
        .then((onValue) {
      setState(() {
        _products = onValue;
        loadMore = true;
        page = 1;
      });
      _refreshController.refreshCompleted();
    }).catchError((e) {
      setState(() {
        errMsg = e.toString();
      });
    });
  }

  void _onLoading() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _services.api
        .getOwnProducts(userModel.user!.cookie, page: page + 1)!
        .then((onValue) {
      setState(() {
        _products = [..._products, ...onValue];
        page = page + 1;
      });
      if (onValue.isEmpty) {
        setState(() {
          loadMore = false;
        });
      }
      _refreshController.loadComplete();
    }).catchError((e) {
      setState(() {
        errMsg = e.toString();
      });
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productModel = Provider.of<ProductModel>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          S.of(context).myProducts,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableProvider<ProductModel>.value(
          value: productModel,
          child: Selector<ProductModel, bool>(
              selector: (_, productModel) => productModel.isLoading,
              builder: (context, isDeleting, child) {
                return LoadingBody(
                  isLoading: isDeleting,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (errMsg != null) {
                        return Center(
                          child: Text(errMsg!),
                        );
                      }
                      return isLoading
                          ? MasonryGridView.count(
                              controller: ScrollController(),
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              itemCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              itemBuilder: (context, value) {
                                return ProductCard(
                                  item: Product.empty('$value'),
                                  width: constraints.maxWidth / 2,
                                  config: ProductConfig.empty(),
                                );
                              },
                              // staggeredTileBuilder: (index) =>
                              //     const StaggeredTile.fit(2),
                            )
                          : SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: loadMore,
                              primary: false,
                              scrollController: _scrollController,
                              controller: _refreshController,
                              onRefresh: _onRefresh,
                              onLoading: _onLoading,
                              child: _products.isNotEmpty
                                  ? MasonryGridView.count(
                                      crossAxisCount: 2,
                                      shrinkWrap: true,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 10,
                                      itemCount: _products.length,
                                      itemBuilder: (context, value) {
                                        return ProductCard(
                                          item: _products[value],
                                          width: constraints.maxWidth / 2,
                                          config: ProductConfig.empty()
                                            ..hPadding = 10
                                            ..vPadding = 10,
                                          onTapDelete: () async {
                                            await _onTapDeleteProduct(context,
                                                product: _products[value]);
                                            _onRefresh();
                                          },
                                        );
                                      },
                                      // staggeredTileBuilder: (index) =>
                                      //     const StaggeredTile.fit(2),
                                    )
                                  : Center(
                                      child:
                                          Text(S.of(context).myProductsEmpty),
                                    ),
                            );
                    },
                  ),
                );
              })),
      floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: _showButton,
          builder: (context, enable, child) {
            return AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: enable ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: enable ? 1 : 0,
                child: GestureDetector(
                  onTap: createProduct,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

extension ProductSellScreenExtension on State<ProductSellScreen> {
  Future<void> _onTapDeleteProduct(context, {required Product product}) async {
    try {
      var user = Provider.of<UserModel>(context, listen: false).user;
      Provider.of<RecentModel>(context, listen: false)
          .removeRecentProduct(product);
      await Provider.of<ProductModel>(context, listen: false)
          .deleteProduct(productId: product.id, cookie: user!.cookie);
      Provider.of<ProductWishListModel>(context, listen: false)
          .removeToWishlist(product);
      Provider.of<CartModel>(context, listen: false)
          .removeItemFromProductId(product.id);
      Tools.showSnackBar(ScaffoldMessenger.of(context),
          '${S.of(context).product} ${product.name} ${S.of(context).hasBeenDeleted}');
    } catch (e) {
      Tools.showSnackBar(ScaffoldMessenger.of(context), e.toString());
      printLog(e);
      rethrow;
    }
  }
}
