import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, Store;
import '../../modules/dynamic_layout/config/geo_search_config.dart';
import '../../modules/dynamic_layout/geo_search/geo_search.dart';
import '../../modules/store_open_option/store_open_option.dart';
import '../../services/service_config.dart';
import '../../services/services.dart';
import '../../widgets/common/webview.dart';
import '../woocommerce/index.dart';
import 'vendor_mixin.dart';

class WCFMWidget extends WooWidget with VendorMixin {
  @override
  Product updateProductObject(Product product, Map? json) {
    if (json!['store'] != null && json['store']['vendor_id'] != null) {
      product.store = Store.fromWCFMJson(json['store']);
    }
    return product;
  }

  @override
  Widget getAdminVendorScreen(context, dynamic user) {
    var base64Str = EncodeUtils.encodeCookie(user.cookie);
    var vendorURL =
        '${ServerConfig().url}/${kVendorConfig.wcfm}&cookie=$base64Str';

    /// Force user to try out the new native store management.
    if (!kVendorConfig.disableNativeStoreManagement) {
      return Services().getVendorAdminApp(
        user: user,
        isFromMV: true,
      );
    }

    return WebView(url: vendorURL, title: S.of(context).vendorAdmin);
  }

  @override
  Widget getDeliveryScreen(context, dynamic user) {
    if (!kVendorConfig.disableDeliveryManagement) {
      return Services().getDeliveryApp(
        user: user,
        isFromMV: true,
      );
    }
    return Container();
  }

  @override
  Widget renderGeoSearch(Map<String, dynamic> config) {
    return GeoSearch(
      geoSearchConfig: GeoSearchConfig.fromJson(config),
    );
  }

  @override
  Widget renderVacationVendor(String userId, String cookie,
      {bool isFromMV = true}) {
    return StoreOpenOptionIndex(
      isFromMV: isFromMV,
      cookie: cookie,
      userId: userId,
      key: const Key('renderOpenCloseVendor'),
    );
  }
}
