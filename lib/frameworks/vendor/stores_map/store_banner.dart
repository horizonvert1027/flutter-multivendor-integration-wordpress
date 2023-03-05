import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../models/entities/store_arguments.dart';
import '../../../models/vendor/store_model.dart';

class StoreBanner extends StatelessWidget {
  final Store? store;
  final double? width;
  final Function? moveToStore;

  const StoreBanner({Key? key, this.store, this.width, this.moveToStore})
      : super(key: key);

  void navigateToStoreDetail(context) {
    Navigator.pushNamed(
      context,
      RouteList.storeDetail,
      arguments: StoreDetailArgument(store: store),
    );
  }

  Widget _buildBanner() {
    final bannerWidth = width! * 0.8;
    final bannerHeight = width! * 0.65;
    return Container(
      width: bannerWidth,
      height: bannerHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(3.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          store!.banner != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3.0),
                      topRight: Radius.circular(3.0)),
                  child: CachedNetworkImage(
                      imageUrl: store!.banner!,
                      fit: BoxFit.cover,
                      width: bannerWidth,
                      height: bannerHeight * 0.35))
              : ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3.0),
                      topRight: Radius.circular(3.0)),
                  child: Image.asset('assets/images/default-store-banner.png',
                      fit: BoxFit.cover,
                      width: bannerWidth,
                      height: bannerHeight * 0.35)),
          const SizedBox(
            height: 5.0,
          ),
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      const SizedBox(width: 5.0),
                      //if (store.isFeatured)
                      const Icon(
                        CupertinoIcons.check_mark_circled,
                        size: 10.0,
                        color: Colors.red,
                      ),
                      //if (store.isFeatured)
                      const SizedBox(width: 9.0),
                      Text(store!.name!,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 5.0),
                      const Icon(
                        CupertinoIcons.phone,
                        size: 8.0,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 9.0),
                      Text(
                          store!.phone!.isEmpty ? 'Unavailable' : store!.phone!,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                  const SizedBox(height: 3.0),
                ],
              ),
              const Expanded(
                child: SizedBox(width: 1),
              ),
              InkWell(
                onTap: moveToStore as void Function()?,
                child: const Icon(
                  CupertinoIcons.arrow_up_right_diamond,
                  size: 24.0,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 10.0)
            ],
          ),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: <Widget>[
              const SizedBox(width: 5.0),
              Icon(CupertinoIcons.star,
                  size: 10.0, color: Colors.yellow.shade700),
              const SizedBox(width: 8.0),
              Text(
                store!.rating != 0.0 ? store!.rating.toString() : 'Not rated',
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: GestureDetector(
        onTap: () => navigateToStoreDetail(context),
        child: _buildBanner(),
      ),
    );
  }
}
