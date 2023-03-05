import 'dart:convert';
import 'dart:core';
import 'dart:io' show HttpClient, X509Certificate;

import 'package:http/io_client.dart';

import '../../../common/constants.dart';

class DokanAPI {
  String? url;

  DokanAPI({this.url});

  String _getOAuthURL(String requestMethod, String endpoint) {
    return '${url!}/wp-json/dokan/v1/$endpoint';
  }

  Future<dynamic> getAsync(String endPoint) async {
    var url = _getOAuthURL('GET', endPoint);
    var response;

    if (debugNetworkProxy) {
      var proxy = isAndroid ? '192.168.1.10:8888' : 'localhost:9090';
      var httpClient = HttpClient();
      httpClient.findProxy = (uri) => 'PROXY $proxy;';
      httpClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => isAndroid);
      var myClient = IOClient(httpClient);
      response = await myClient.get(url.toUri()!);
    } else {
      response = await httpGet(url.toUri()!);
    }

    return json.decode(response.body);
  }
}
