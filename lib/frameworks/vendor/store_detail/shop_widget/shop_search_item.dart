import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../common/tools/image_tools.dart';
import '../../../../common/tools/price_tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';

class ShopSearchItem extends StatelessWidget {
  final Product? product;
  const ShopSearchItem({Key? key, required this.product}) : super(key: key);
  const ShopSearchItem.loading({
    Key? key,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (product == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        child: Skeleton(height: 100, width: size.width),
      );
    }

    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final isOnSale = (product?.onSale ?? false);
    final isInStock = (product?.inStock ?? false);
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          RouteList.productDetail,
          arguments: product,
        );
      },
      child: Container(
        height: 100,
        width: size.width,
        margin: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  ImageResize(url: product!.imageFeature ?? kDefaultImage),
                  if (isOnSale)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 2.0),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(5.0)),
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
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product!.name!, style: theme.textTheme.titleLarge),
                  if (product?.regularPrice != null)
                    Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
