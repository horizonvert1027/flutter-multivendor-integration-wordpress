import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../shop_model/export.dart';
import '../shop_widget/shop_review_item.dart';

class ShopReviewScreen extends StatefulWidget {
  const ShopReviewScreen({Key? key}) : super(key: key);

  @override
  State<ShopReviewScreen> createState() => _ShopReviewScreenState();
}

class _ShopReviewScreenState extends State<ShopReviewScreen> {
  final _controller = RefreshController();

  void _onRefresh() {
    final model = Provider.of<ShopReviewModel>(context, listen: false);
    model.getReviews().then((value) {
      _controller.refreshCompleted();
      if (value.isEmpty) {
        _controller.loadNoData();
        return;
      }
      _controller.loadComplete();
    });
  }

  void _onLoadMore() {
    final model = Provider.of<ShopReviewModel>(context, listen: false);
    model.loadReviews().then((value) {
      if (value.isEmpty) {
        _controller.loadNoData();
        return;
      }
      _controller.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).reviews,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Consumer<ShopReviewModel>(builder: (_, model, __) {
        final isEmpty =
            model.reviews.isEmpty && model.state == ShopReviewState.loaded;
        final isLoading = model.state == ShopReviewState.loading;
        return SmartRefresher(
          controller: _controller,
          enablePullDown: true,
          enablePullUp: true,
          onLoading: _onLoadMore,
          onRefresh: _onRefresh,
          child: isEmpty
              ? Center(
                  child: Text(S.of(context).noReviews),
                )
              : ListView.builder(
                  itemBuilder: (_, index) => isLoading
                      ? const ShopReviewItem.loading()
                      : ShopReviewItem(review: model.reviews[index]),
                  itemCount: isLoading ? 5 : model.reviews.length,
                ),
        );
      }),
    );
  }
}
