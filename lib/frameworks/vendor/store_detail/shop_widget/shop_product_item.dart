import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools/image_tools.dart';
import '../../../../common/tools/price_tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/app_model.dart';
import '../../../../models/entities/product.dart';

class ProductShopItem extends StatelessWidget {
  final Product? product;

  const ProductShopItem({Key? key, required this.product}) : super(key: key);

  const ProductShopItem.loading({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    if (product == null) {
      return AspectRatio(
        aspectRatio: 0.8,
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Skeleton()),
      );
    }
    final isOnSale = (product?.onSale ?? false);

    final isInStock = (product?.inStock ?? false);
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteList.productDetail,
          arguments: product,
        );
      },
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ImageResize(
                      url: product!.imageFeature,
                      fit: BoxFit.cover,
                      height: 170,
                      // width: double.maxFinite,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    product!.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  if (product?.regularPrice != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isInStock) ...[
                            Expanded(
                              child: Text(
                                  PriceTools.getCurrencyFormatted(
                                    product!.regularPrice,
                                    currencyRate,
                                    currency: currency,
                                  )!,
                                  style: TextStyle(
                                    decoration: isOnSale
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  )),
                            ),
                            if (isOnSale)
                              Expanded(
                                child: Text(PriceTools.getCurrencyFormatted(
                                  product!.salePrice,
                                  currencyRate,
                                  currency: currency,
                                )!),
                              ),
                          ],
                          if (!isInStock)
                            Expanded(
                              child: Text(
                                S.of(context).outOfStock,
                                style: theme.textTheme.bodyLarge!
                                    .copyWith(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              if (isOnSale)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 2.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(5.0)),
                    ),
                    child: Text(
                      S.of(context).onSale,
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
