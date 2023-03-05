import 'dart:convert' as convert;
import 'dart:core';

import 'package:quiver/strings.dart' show isNotBlank;

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/entities/paging_response.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/index.dart' show Category, Order, Product, Review, User;
import '../../../models/vendor/store_model.dart';
import '../../woocommerce/services/woo_commerce.dart';
import 'dokan_api.dart';

class DokanService extends WooCommerceService {
  DokanService({
    required String domain,
    String? blogDomain,
    required String consumerKey,
    required String consumerSecret,
  })  : dokanApi = DokanAPI(url: domain),
        super(
          domain: domain,
          blogDomain: blogDomain,
          consumerSecret: consumerSecret,
          consumerKey: consumerKey,
        );

  final DokanAPI dokanApi;

  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      var niceName = '${firstName!} ${lastName!}';
      var endPoint =
          '$domain/wp-json/api/flutter_user/sign_up/?insecure=cool&$isSecure'
              .toUri()!;
      if (kAdvanceConfig.enableNewSMSLogin) {
        endPoint =
            '$domain/wp-json/api/flutter_user/sign_up_2/?insecure=cool&$isSecure'
                .toUri()!;
      }
      final response = await httpPost(endPoint,
          body: convert.jsonEncode({
            'user_email': username,
            'user_login': username,
            'username': username,
            'first_name': firstName,
            'last_name': lastName,
            'user_pass': password,
            'email': username,
            'user_nicename': niceName,
            'display_name': niceName,
            'phone': phoneNumber,
            'role': isVendor ? 'seller' : 'subscriber'
          }));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        var cookie = body['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = body['message'];
        throw Exception(message ?? 'Can not create the user.');
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Store>> getFeaturedStores() async {
    var page = 1;
    var list = <Store>[];
    while (true) {
      try {
        var response =
            await dokanApi.getAsync('stores?page=$page&per_page=100');
        if (response.length == 0) {
          return list;
        }
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else {
          for (var item in response) {
            if (item['featured']) list.add(Store.fromDokanJson(item));
          }
          page++;
        }
      } catch (e) {
        return list;
      }
    }
  }

  @override
  Future<List<Product>>? getProductsByStore({
    storeId,
    int? page,
    int? perPage,
    int? catId,
    bool? onSale,
    String? order,
    String? orderBy,
    String? searchTerm,
    String lang = 'en',
  }) async {
    var list = <Product>[];
    try {
      var endpoint =
          '$domain/wp-json/api/flutter_multi_vendor/products/owner?id=$storeId';
      if (page == null || perPage == null) {
        page = 1;
        perPage = 10;
      }
      endpoint += '&page=$page&per_page=$perPage';
      if (catId != null && catId != -1) {
        endpoint += '&category=$catId';
      }
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        endpoint += '&search=$searchTerm';
      }
      if (onSale != null && onSale) {
        endpoint += '&on_sale=true';
      }
      if (order != null && orderBy != null) {
        endpoint += '&order=$order&orderby=$orderBy';
      }
      if (kAdvanceConfig.isMultiLanguages) {
        endpoint += '&lang=$lang';
      }

      final response = await httpGet(endpoint.toUri()!);
      var result = convert.jsonDecode(response.body);
      for (var item in result) {
        final product = Product.fromJson(item);

        if (item['store'] != null) {
          try {
            product.store = Store.fromDokanJson(item['store']);
          } catch (e) {
            printLog('parse store: $e');
          }
        }
        list.add(product);
      }
    } catch (e) {
      printLog(e);
    }
    return list;
  }

  @override
  Future<List<Review>> getReviewsStore(
      {storeId, page = 1, perPage = 100}) async {
    try {
      var list = <Review>[];
      var response = await dokanApi.getAsync('stores/$storeId/reviews');

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Review.fromDokanJson(item));
        }
        return list;
      }
    } catch (e) {
      return <Review>[];
    }
  }

  @override
  Future<Store> getStoreInfo(storeId) async {
    try {
      var response = await dokanApi.getAsync('stores/$storeId');

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        return Store.fromDokanJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future? getJWTToken() {
    return null;
  }

  @override
  Future<List<Store>> searchStores({String? keyword, int? page}) async {
    try {
      var list = <Store>[];
      var endPoint = 'stores?';
      if (keyword?.isNotEmpty ?? false) {
        endPoint += 'search=$keyword';
      }

      endPoint += '&page=$page';

      var response = await dokanApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (item['enabled'] == true) {
            list.add(Store.fromDokanJson(item));
          }
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Store>> getNearbyStores(Prediction prediction,
      {int page = 1, int perPage = 10, int radius = 10, String? name}) async {
    var list = <Store>[];
    try {
      var endpoint =
          'flutter/get-nearby-stores?latitude=${prediction.lat}&longitude=${prediction.long}&distance=$radius';
      if (name != null && name.trim().isNotEmpty) {
        endpoint += '&search=$name';
      }
      var response = await wcApi.getAsync(endpoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          var store = Store.fromDokanJson(item);
          if (store.lat != null && store.long != null) {
            list.add(store);
          }
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Order>> getMyOrders({
    User? user,
    dynamic cursor,
    String? cartId,
  }) async {
    try {
      /// To remove dokan sub orders from result
      var response = await wcApi.getAsync(
          'orders?customer=${user!.id}&per_page=20&page=$cursor&order=desc&orderby=id&parent=0&dummy=${DateTime.now().millisecondsSinceEpoch}');
      var list = <Order>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesByPage(
      {lang,
      page,
      limit,
      storeId,
      String? searchTerm,
      int? parent,
      bool useCompute = true}) async {
    var list = <Category>[];
    try {
      var endpoint =
          '$domain/wp-json/api/flutter_multi_vendor/product-categories';
      const perPage = 100;
      page ??= 1;
      endpoint += '?page=$page&limit=$perPage&platform=dokan';
      if (storeId != null) {
        endpoint += '&id=$storeId';
      }
      if (lang != null && kAdvanceConfig.isMultiLanguages) {
        endpoint += '&lang=$lang';
      }
      if (kAdvanceConfig.hideEmptyCategories) {
        endpoint += '&hide_empty=true';
      }
      final response = await httpGet(endpoint.toUri()!);
      var result = convert.jsonDecode(response.body);
      for (var item in result) {
        final cat = Category.fromJson(item);
        if (cat.id != null) {
          list.add(cat);
        }
      }
    } catch (e) {
      printLog(e);
    }
    return list;
  }

  @override
  Future<Store?> getStoreByPermalink(String storePermaLink) async {
    try {
      final response = await httpGet(
          '$domain/wp-json/wc/v2/flutter/vendor/dynamic?url=$storePermaLink'
              .toUri()!);

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Store.fromDokanJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }
}
