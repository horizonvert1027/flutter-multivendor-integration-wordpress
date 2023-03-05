import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools/tools.dart';
import '../../models/entities/store_arguments.dart';
import '../../modules/dynamic_layout/config/app_config.dart';
import '../../screens/chat/chat_arguments.dart';
import '../../screens/chat/chat_screen.dart';
import '../../services/services.dart';
import 'products/create_product_screen.dart';
import 'products/product_sell_screen.dart';
import 'store/vendor_categories_screen.dart';
import 'store_detail/store_detail_screen.dart';
import 'stores_map/map_screen.dart';

class VendorRoute {
  static dynamic getRoutesWithSettings(RouteSettings settings) {
    final routes = {
      RouteList.storeDetail: (context) {
        final arguments = settings.arguments;
        if (arguments is StoreDetailArgument) {
          return StoreDetailScreen(store: arguments.store);
        }
        return errorPage('Error argument StoreDetail');
      },
      RouteList.vendorChat: (context) {
        final arguments = settings.arguments;
        if (arguments is ChatArguments) {
          return Services().firebase.renderChatScreen(
                senderUser: arguments.senderUser,
                receiverEmail: arguments.receiverEmail,
                receiverName: arguments.receiverName,
              );
        }
        return errorPage('Error argument ChatScreen');
      },
      RouteList.vendorCategory: (context) {
        final data = settings.arguments;
        if (data is TabBarMenuConfig) {
          return VendorCategoriesScreen(
              layout: data.jsonData['categoryLayout'],
              enableParallax: data.jsonData['parallax'] ?? false,
              parallaxImageRatio:
                  Tools.formatDouble(data.jsonData['parallaxImageRatio']));
        }
        return const VendorCategoriesScreen();
      },
      RouteList.createProduct: (context) => const CreateProductScreen(),
      RouteList.productSell: (context) => ProductSellScreen(),
      RouteList.listChat: (_) {
        final isVendor = settings.arguments;
        if (isVendor is bool && isVendor == true) {
          return const ChatScreen(isVendor: true);
        }
        return const ChatScreen();
      },
      RouteList.map: (_) => const MapScreen(),
    };
    if (routes.containsKey(settings.name)) {
      return routes[settings.name!];
    }
    return (context) => errorPage('Page not found');
  }

  static Widget errorPage(String title) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(title),
        ),
      );
}
