import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../common/config.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart' show Review;
import '../../../../screens/base_screen.dart';
import '../../../../services/index.dart';
import '../../../../widgets/common/start_rating.dart';

class Reviews extends StatefulWidget {
  final int? storeId;

  const Reviews({this.storeId});

  @override
  BaseScreen<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends BaseScreen<Reviews> {
  List<Review> list = [];
  bool isFetching = false;
  final _controller = RefreshController();
  var _page = 1;
  final _perPage = 10;

  @override
  void afterFirstLayout(BuildContext context) async {
    try {
      await _onRefresh();
    } catch (e) {
      setState(() {
        isFetching = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    if (isFetching) {
      return;
    }
    _page = 1;
    list.clear();
    setState(() {
      isFetching = true;
    });

    list = await Services().api.getReviewsStore(
        storeId: widget.storeId, page: _page, perPage: _perPage)!;

    if (list.isEmpty) {
      _controller.loadNoData();
    } else {
      _controller.loadComplete();
    }
    _controller.refreshCompleted();

    setState(() {
      isFetching = false;
    });
  }

  Future<void> _onLoadMore() async {
    if (isFetching) {
      return;
    }
    _page++;
    final tmp = await Services().api.getReviewsStore(
        storeId: widget.storeId, page: _page, perPage: _perPage)!;
    if (tmp.isEmpty) {
      _controller.loadNoData();
      return;
    }
    list.addAll(tmp);
    _controller.loadComplete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isFetching) return kLoadingWidget(context);
    if (!isFetching && list.isEmpty) {
      return Center(child: Text(S.of(context).noReviews));
    }
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
      padding: const EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: SmartRefresher(
        controller: _controller,
        onRefresh: _onRefresh,
        onLoading: _onLoadMore,
        enablePullUp: true,
        enablePullDown: true,
        child: ListView.builder(
          itemBuilder: (context, index) => ReviewItem(
            review: list[index],
          ),
          itemCount: list.length,
        ),
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review? review;

  const ReviewItem({this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: ExtendedImage.network(
                  review!.avatar!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  cache: true,
                  enableLoadState: false,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    review!.name!,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  SmoothStarRating(
                      allowHalfRating: true,
                      starCount: 5,
                      rating: review!.rating ?? 0.0,
                      size: 15,
                      color: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      spacing: 0.0)
                ],
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            review!.review!,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(DateFormat.yMMMMd('en_US').format(review!.createdAt),
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary)),
          )
        ],
      ),
    );
  }
}
