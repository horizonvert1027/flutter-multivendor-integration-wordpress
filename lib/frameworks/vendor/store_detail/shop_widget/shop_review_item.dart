import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../models/entities/index.dart';
import '../../../../widgets/common/start_rating.dart';

class ShopReviewItem extends StatelessWidget {
  final Review? review;

  const ShopReviewItem({Key? key, required this.review}) : super(key: key);
  const ShopReviewItem.loading({Key? key, this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Skeleton(
                height: 30,
                width: 30,
                cornerRadius: 30.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Skeleton(
                      height: 30,
                      width: 100,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Skeleton(
                      height: 10,
                      width: 50,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Skeleton(
                      height: 10,
                      width: 100,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Skeleton(
                      height: 10,
                      width: 80,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(review?.avatar ?? kDefaultImage),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review!.name ?? review!.email ?? '',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  SmoothStarRating(
                    rating: review!.rating,
                    size: 10.0,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    review!.review ?? '',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    Tools.convertDateTime(review!.createdAt)!,
                    style:
                        theme.textTheme.bodySmall!.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
