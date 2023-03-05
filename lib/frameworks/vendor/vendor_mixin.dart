import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        CartModel,
        Product,
        Store,
        UserModel,
        VendorShippingMethodModel;
import '../../screens/order_history/models/list_order_history_model.dart';
import 'checkout/shipping_method_screen.dart';
import 'featured_vendors_layout.dart';
import 'repositories/list_order_vendor_repository.dart';
import 'route.dart';
import 'store/vendor_categories_screen.dart';
import 'store_detail/store_detail_screen_from_config.dart';
import 'stores_map/map_screen.dart';
import 'vendor_info.dart';
import 'vendor_orders_screen.dart';

/// The mixin function for Vendor framework
mixin VendorMixin {
  void loadShippingMethods(
      BuildContext context, CartModel cartModel, bool beforehand) {
    Future.delayed(Duration.zero, () {
      var results = <String, Store?>{};
      if (!kVendorConfig.disableVendorShipping) {
        final item = Provider.of<CartModel>(context, listen: false).item;
        item.values.toList().forEach((Product? product) {
          if (product!.store != null && product.store!.id != null) {
            results[product.store!.id.toString()] = product.store;
          } else {
            results['-1'] = null;
          }
        });
      } else {
        results['-1'] = null;
      }
      var langCode = Provider.of<AppModel>(context, listen: false).langCode;
      Provider.of<VendorShippingMethodModel>(context, listen: false)
          .getShippingMethods(
              cartModel: cartModel,
              stores: results.values.toList(),
              langCode: langCode);
    });
  }

  Widget renderVendorInfo(Product? product) => VendorInfo(product);

  Widget renderVendorOrder(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => ListOrderHistoryModel(
                    repository: ListOrderVendorRepository(
                  user: Provider.of<UserModel>(context, listen: false).user!,
                )),
                child: const VendorOrdersScreen(),
              ),
            ),
          );
        },
        leading: Icon(
          Icons.shopping_cart,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).shopOrders,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget renderFeatureVendor(config) {
    return FeaturedVendorsLayout(config: config);
  }

  Widget renderShippingMethods(BuildContext context,
      {Function? onBack, Function? onNext}) {
    return ShippingMethods(onBack: onBack, onNext: onNext);
  }

  Widget renderVendorCategoriesScreen(data) {
    return VendorCategoriesScreen(
      layout: data['categoryLayout'],
      enableParallax: data['parallax'] ?? false,
      parallaxImageRatio: Tools.formatDouble(data['parallaxImageRatio']),
    );
  }

  Widget renderMapScreen() => const MapScreen();

  Widget renderShippingMethodInfo(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    if (kPaymentConfig.enableShipping) {
      return Column(
        children: <Widget>[
          for (var i = 0; i < cartModel.selectedShippingMethods.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${cartModel.selectedShippingMethods[i].shippingMethods[0].title}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        if (cartModel.selectedShippingMethods[i].store !=
                                null &&
                            cartModel.selectedShippingMethods[i].store.name !=
                                '')
                          Text(
                            '${cartModel.selectedShippingMethods[i].store.name}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    PriceTools.getCurrencyFormatted(
                        cartModel
                            .selectedShippingMethods[i].shippingMethods[0].cost,
                        currencyRate,
                        currency: cartModel.currencyCode)!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  )
                ],
              ),
            )
        ],
      );
    } else {
      return Container();
    }
  }

  Widget renderVendorScreen(String? storeID) =>
      StoreDetailScreenFromConfig(storeId: storeID);

  /// Get vendor route
  dynamic getVendorRoute(settings) {
    return VendorRoute.getRoutesWithSettings(settings);
  }
}
