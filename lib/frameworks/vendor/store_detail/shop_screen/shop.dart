import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../shop_model/export.dart';
import '../shop_widget/shop_product_item.dart';
import 'shop_product_list_screen.dart';

class Shop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSaleModel = Provider.of<ShopOnSaleModel>(context);
    final onLatestModel = Provider.of<ShopNewModel>(context);
    final onPopularModel = Provider.of<ShopPopularModel>(context);

    if ((onSaleModel.state == ShopModelState.loaded &&
            onLatestModel.state == ShopModelState.loaded &&
            onPopularModel.state == ShopModelState.loaded) &&
        (onSaleModel.products.isEmpty &&
            onLatestModel.products.isEmpty &&
            onPopularModel.products.isEmpty)) {
      return Center(
        child: Text(S.of(context).noData),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: const [
          ShopList.onSale(),
          ShopList.latest(),
          ShopList.popular(),
        ],
      ),
    );
  }
}

enum ShopListType { popular, latest, onSale }

class ShopList extends StatelessWidget {
  final ShopListType type;

  const ShopList.popular({Key? key, this.type = ShopListType.popular})
      : super(key: key);
  const ShopList.latest({Key? key, this.type = ShopListType.latest})
      : super(key: key);
  const ShopList.onSale({Key? key, this.type = ShopListType.onSale})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void toShopList(String name, model) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        switch (type) {
          case ShopListType.popular:
            return ShopProductListScreen.popular(
              name: name,
              ctx: context,
            );
          case ShopListType.latest:
            return ShopProductListScreen.latest(
              name: name,
              ctx: context,
            );

          default:
            return ShopProductListScreen.onSale(
              name: name,
              ctx: context,
            );
        }
      }));
    }

    final theme = Theme.of(context);
    var title = S.of(context).onSale;
    var model;
    if (type == ShopListType.popular) {
      title = S.of(context).popular;
      model = Provider.of<ShopPopularModel>(context);
    }
    if (type == ShopListType.latest) {
      title = S.of(context).latestProducts;
      model = Provider.of<ShopNewModel>(context);
    }
    if (type == ShopListType.onSale) {
      model = Provider.of<ShopOnSaleModel>(context);
    }
    final maxLength = model.products.length < 10 ? model.products.length : 10;
    if (model.products.isEmpty && model.state == ShopModelState.loaded) {
      return Container();
    }
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (maxLength == 10)
                GestureDetector(
                    onTap: () => toShopList(title, model),
                    child: Text(S.of(context).seeAll)),
            ],
          ),
          const SizedBox(height: 10.0),
          LayoutBuilder(builder: (_, constraint) {
            if (model.state == ShopModelState.loading) {
              return SizedBox(
                height: 250.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => const ProductShopItem.loading(),
                  itemCount: 20,
                ),
              );
            }

            return SizedBox(
              height: 250.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => ProductShopItem(
                  product: model.products[index],
                ),
                itemCount: maxLength,
              ),
            );
          }),
        ],
      ),
    );
  }
}
