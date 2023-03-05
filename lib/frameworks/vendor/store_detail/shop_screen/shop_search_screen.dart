import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../generated/l10n.dart';
import '../shop_model/export.dart';
import '../shop_widget/shop_search_item.dart';

class ShopSearchScreen extends StatefulWidget {
  @override
  State<ShopSearchScreen> createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends State<ShopSearchScreen> {
  final _controller = RefreshController();
  final _textController = TextEditingController();

  Future<void> _onLoading() async {
    final model = Provider.of<ShopSearchModel>(context, listen: false);
    final list = await model.loadProducts();
    if (list.isEmpty) {
      _controller.loadNoData();
    } else {
      _controller.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ShopSearchModel>(context);
    final isEmpty = _textController.text.isNotEmpty &&
        model.products.isEmpty &&
        model.state == ShopModelState.loaded;
    final isNotSearching = _textController.text.isEmpty &&
        model.products.isEmpty &&
        model.state == ShopModelState.loaded;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).primaryColorLight,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextField(
            controller: _textController,
            onChanged: model.search,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: S.of(context).atLeastThreeCharacters,
              contentPadding: const EdgeInsets.all(0.0),
            ),
          ),
        ),
        Expanded(
          child: SmartRefresher(
            controller: _controller,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: _onLoading,
            child: isNotSearching
                ? Center(
                    child: Text(S.of(context).searchForItems),
                  )
                : isEmpty
                    ? Center(child: Text(S.of(context).noData))
                    : ListView.builder(
                        itemBuilder: (_, index) {
                          if (model.state == ShopModelState.loading) {
                            return const ShopSearchItem.loading();
                          }
                          return ShopSearchItem(product: model.products[index]);
                        },
                        itemCount: model.state == ShopModelState.loading
                            ? 5
                            : model.products.length,
                      ),
          ),
        ),
      ],
    );
  }
}
