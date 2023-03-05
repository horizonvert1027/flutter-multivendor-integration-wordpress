import 'dart:convert' as convert;
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/entities/paging_response.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/entities/vacation_settings.dart';
import '../../../models/index.dart' show Blog, Category, Product, Review, User;
import '../../../models/vendor/store_model.dart';
import '../../woocommerce/services/woo_commerce.dart';
import 'wcfm_api.dart';

class WCFMService extends WooCommerceService {
  final WCFMAPI wcfmApi;

  String? jwtToken;

  WCFMService({
    required String domain,
    String? blogDomain,
    required String consumerKey,
    required String consumerSecret,
  })  : wcfmApi = WCFMAPI(url: domain),
        super(
          domain: domain,
          blogDomain: blogDomain,
          consumerSecret: consumerSecret,
          consumerKey: consumerKey,
        );

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
            'role': isVendor ? 'wcfm_vendor' : 'subscriber'
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
            product.store = Store.fromWCFMJson(item['store']);
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
      {storeId, page = 1, perPage = 10}) async {
    var list = <Review>[];
    try {
      var response = await httpGet(
        '$domain/wp-json/api/flutter_multi_vendor/get-reviews?store_id=$storeId&page=$page&per_page=$perPage&status_type=approved'
            .toUri()!,
      );
      var result = convert.jsonDecode(response.body);

      for (var item in result) {
        if (int.parse(item['vendor_id']) == storeId) {
          list.add(Review.fromWCFMJson(item));
        }
      }
    } catch (e) {
      printLog(e);
    }
    return list;
  }

  @override
  Future<Store?> getStoreInfo(storeId) async {
    try {
      var response = await wcApi.getAsync('flutter/wcfm-stores/$storeId');

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        if (response['settings'] == null) {
          return null;
        }
        return Store.fromWCFMJson(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Store>> searchStores({String? keyword, int? page = 10}) async {
    try {
      var list = <Store>[];
      var endPoint = 'flutter/wcfm-stores?';
      if (keyword?.isNotEmpty ?? false) {
        endPoint += 'search=$keyword';
      }

      endPoint += '&page=$page';

      var response = await wcApi.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Store.fromWCFMJson(item));
          //if (!item['disable_vendor']) list.add(Store.fromWCFMJson(item));
        }
        return list;
      }
    } catch (e) {
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
            await wcApi.getAsync('flutter/wcfm-stores?page=$page&per_page=100');
        if (response.length == 0) {
          return list;
        }
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else {
          for (var item in response) {
            if (!item['disable_vendor']) list.add(Store.fromWCFMJson(item));
          }
          page++;
        }
      } catch (e) {
        return list;
      }
    }
  }

  @override
  Future<List<Store>> getNearbyStores(Prediction prediction,
      {int page = 1, int perPage = 10, int radius = 10, String? name}) async {
    var list = <Store>[];

    try {
      var endpoint =
          'flutter/wcfm-stores?page=$page&per_page=$perPage&wcfmmp_radius_lat=${prediction.lat}&wcfmmp_radius_lng=${prediction.long}&wcfmmp_radius_range=$radius';
      if (name != null && name.trim().isNotEmpty) {
        endpoint += '&search=$name';
      }
      var response = await wcApi.getAsync(endpoint);

      if (response.length == 0) {
        return list;
      }
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          if (!item['disable_vendor']) {
            final store = Store.fromWCFMJson(item);
            if (store.lat == null || store.long == null) {
              continue;
            }
            list.add(Store.fromWCFMJson(item));
          }
        }
      }
    } catch (e) {
      printLog(e);
    }
    return list;
  }

  @override
  Future<PagingResponse<Blog>> getBlogs(dynamic cursor) async {
    try {
      var param =
          '_embed&page=$cursor${kAdvanceConfig.alwaysRefreshBlog ? '&dummy=${DateTime.now().millisecondsSinceEpoch}' : ''}';
      // if (categories != null) {
      //   param += '&categories=$categories';
      // }
      final response =
          await http.get('$domain/wp-json/wp/v2/posts?$param'.toUri()!);
      if (response.statusCode != 200) {
        return const PagingResponse();
      }
      List data = convert.jsonDecode(response.body);
      return PagingResponse(
          data: data.map((e) {
        return Blog.fromJson(e);
      }).toList());
    } on Exception catch (_) {
      return const PagingResponse();
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
      endpoint += '?page=$page&limit=$perPage';
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
        return Store.fromWCFMJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<VacationSettings?> getVacationSettings(String storeId) async {
    try {
      final response = await httpGet(
          '$domain/wp-json/wc/v2/flutter/vendor/vacation?store_id=$storeId'
              .toUri()!);

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return VacationSettings.fromJson(body);
      }
    } catch (e) {
      printLog(e);
    }
    return null;
  }

  @override
  Future<bool?> setVacationSettings(
      String cookie, VacationSettings vacationSettings) async {
    try {
      var data = vacationSettings.toJson();
      data['cookie'] = cookie;
      final response = await httpPost(
          '$domain/wp-json/wc/v2/flutter/vendor/vacation'.toUri()!,
          body: data);
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      printLog(e);
    }
    return false;
  }
}
