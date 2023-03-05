import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:provider/provider.dart';

import '../../../../models/index.dart';
import '../shop_model/shop_category_model.dart';
import 'shop_product_list_screen.dart';

class ShopCategoryScreen extends StatefulWidget {
  const ShopCategoryScreen({Key? key}) : super(key: key);

  @override
  State<ShopCategoryScreen> createState() => _ShopCategoryScreenState();
}

class _ShopCategoryScreenState extends State<ShopCategoryScreen> {
  void _toShopList(Category cat) {
    final model = Provider.of<ShopCategoryModel>(context, listen: false);
    model.setCatId(cat.id!);
    model.getProducts();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ShopProductListScreen.category(
              name: cat.name,
              ctx: context,
            )));
  }

  Widget _catItem(Category cat) {
    return InkWell(
      onTap: () => _toShopList(cat),
      child: Row(
        children: [
          const SizedBox(width: 15.0, height: 35.0),
          Expanded(
              child: Text(
            cat.name ?? '',
            style: Theme.of(context).textTheme.titleMedium,
          )),
          const Icon(Icons.arrow_forward_ios_outlined,
              size: 15.0, color: Colors.grey),
          const SizedBox(width: 15.0),
        ],
      ),
    );
  }

  Widget _catLoadingItem() {
    return Row(
      children: const [
        SizedBox(
          width: 10.0,
        ),
        Expanded(
            child: Skeleton(
          height: 30,
          width: 100,
        )),
        Icon(Icons.arrow_forward_ios_outlined, size: 15.0, color: Colors.grey),
        SizedBox(
          width: 10.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopCategoryModel>(
      builder: (_, model, __) => ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (_, index) => const Divider(),
        itemBuilder: (_, index) => model.isGettingCategories
            ? _catLoadingItem()
            : _catItem(model.categories[index]),
        itemCount: model.isGettingCategories ? 5 : model.categories.length,
      ),
    );
  }
}
