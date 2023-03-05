import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, Store;
import '../../modules/dynamic_layout/config/geo_search_config.dart';
import '../../modules/dynamic_layout/geo_search/geo_search.dart';
import '../../services/service_config.dart';
import '../../services/services.dart';
import '../../widgets/common/webview.dart';
import '../woocommerce/index.dart';
import 'vendor_mixin.dart';

class DokanWidget extends WooWidget with VendorMixin {
  @override
  Product updateProductObject(Product product, Map? json) {
    if (json!['store'] != null && json['store']['id'] != null) {
      product.store = Store.fromDokanJson(json['store']);
    }
    return product;
  }

  @override
  Widget getAdminVendorScreen(context, dynamic user) {
    /// Force user to try out the new native store management.
    if (!kVendorConfig.disableNativeStoreManagement) {
      return Services().getVendorAdminApp(
        user: user,
        isFromMV: true,
      );
    }

    var base64Str = EncodeUtils.encodeCookie(user.cookie);

    var vendorURL = '${ServerConfig().url}/${kVendorConfig.dokan}';
    vendorURL +=
        vendorURL.contains('?') ? '&cookie=$base64Str' : '?cookie=$base64Str';
    return WebView(url: vendorURL, title: S.of(context).vendorAdmin);
  }

  @override
  Widget renderGeoSearch(Map<String, dynamic> config) {
    return GeoSearch(
      geoSearchConfig: GeoSearchConfig.fromJson(config),
    );
  }
}
