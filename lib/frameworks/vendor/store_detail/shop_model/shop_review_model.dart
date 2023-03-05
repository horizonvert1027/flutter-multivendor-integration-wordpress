import 'package:flutter/material.dart';

import '../../../../models/entities/review.dart';
import '../../../../services/index.dart';

enum ShopReviewState { loading, loaded }

class ShopReviewModel extends ChangeNotifier {
  final _services = Services();
  final _storeId;
  final _perPage = 10;
  int _page = 1;
  final List<Review> _reviews = [];
  List<Review> get reviews => _reviews;
  ShopReviewState _state = ShopReviewState.loading;
  ShopReviewState get state => _state;
  bool _isDisposed = false;

  ShopReviewModel(this._storeId) {
    getReviews();
  }

  void _updateState(state) {
    if (!_isDisposed) {
      _state = state;
      notifyListeners();
    }
  }

  Future<List<Review>> getReviews() async {
    if (state == ShopReviewState.loaded) {
      _updateState(ShopReviewState.loading);
    }
    reviews.clear();
    _page = 1;
    final list = await _services.api
        .getReviewsStore(storeId: _storeId, page: _page, perPage: _perPage)!;
    if (list.isNotEmpty) {
      reviews.addAll(list);
    }
    _updateState(ShopReviewState.loaded);
    return list;
  }

  Future<List<Review>> loadReviews() async {
    _page++;
    final list = await _services.api
        .getReviewsStore(storeId: _storeId, page: _page, perPage: _perPage)!;
    if (list.isNotEmpty) {
      reviews.addAll(list);
    }
    _updateState(ShopReviewState.loaded);
    return list;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
