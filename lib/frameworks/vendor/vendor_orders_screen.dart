import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inspireui/widgets/skeleton_widget/skeleton_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart';
import '../../screens/order_history/index.dart';
import '../../screens/order_history/views/widgets/order_price.dart';
import '../../widgets/common/paging_list.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen();
  @override
  State<VendorOrdersScreen> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<VendorOrdersScreen> {
  var mapOrderHistoryDetailModel = <int, OrderHistoryDetailModel>{};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          S.of(context).shopOrders,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0.0,
      ),
      body: PagingList<ListOrderHistoryModel, Order>(
        onRefresh: mapOrderHistoryDetailModel.clear,
        itemBuilder: (_, order, index) {
          if (mapOrderHistoryDetailModel[index] == null) {
            final orderHistoryDetailModel = OrderHistoryDetailModel(
              order: order,
              user: Provider.of<UserModel>(context, listen: false).user!,
            );
            mapOrderHistoryDetailModel[index] = orderHistoryDetailModel;
          }
          return ChangeNotifierProvider<OrderHistoryDetailModel>.value(
            value: mapOrderHistoryDetailModel[index]!,
            child: OrderItem(),
          );
        },
        lengthLoadingWidget: 3,
        loadingWidget: const _OrderListLoadingItem(),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    return Consumer<OrderHistoryDetailModel>(
        builder: (context, orderDetailModel, child) {
      final order = orderDetailModel.order;
      return Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteList.orderDetail,
                arguments: OrderDetailArguments(
                    model: orderDetailModel,
                    enableReorder: false,
                    disableReview: true),
              );
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('#${order.number}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_right),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(S.of(context).orderDate),
                Text(
                  DateFormat('dd/MM/yyyy').format(order.createdAt!),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(S.of(context).status),
                Text(
                  order.status!.getTranslation(context).toUpperCase(),
                  style: TextStyle(
                      color: kOrderStatusColor[order.status] != null
                          ? HexColor(kOrderStatusColor[order.status])
                          : Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(S.of(context).paymentMethod),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: Text(
                  order.paymentMethodTitle!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(S.of(context).total),
                OrderPrice(
                  order: order,
                  currencyRate: currencyRate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20)
        ],
      );
    });
  }
}

class _OrderListLoadingItem extends StatelessWidget {
  const _OrderListLoadingItem();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var isDarkTheme = Provider.of<AppModel>(context, listen: false).darkTheme;
    return Container(
      width: size.width,
      height: 200,
      margin: const EdgeInsets.only(
          bottom: 10.0, left: 10.0, right: 10.0, top: 5.0),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                color: isDarkTheme ? Colors.black87 : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: const Skeleton(
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(
                          height: 25.0,
                          width: Random().nextInt(150) + 100.0,
                        ),
                        const SizedBox(height: 5),
                        Skeleton(
                          height: 14.0,
                          width: Random().nextInt(100) + 50.0,
                        ),
                        const Expanded(
                          child: SizedBox(
                            height: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Skeleton(
                              height: 14.0,
                              width: Random().nextInt(50) + 100.0,
                            ),
                            const Expanded(
                              child: SizedBox(
                                width: 1,
                              ),
                            ),
                            const Skeleton(
                              height: 14.0,
                              width: 100.0,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: isDarkTheme ? Colors.black26 : Colors.grey.shade300,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Skeleton(
                          height: 18.0,
                          width: 70.0,
                        ),
                        SizedBox(height: 10),
                        Skeleton(
                          height: 14.0,
                          width: 20.0,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Skeleton(
                          height: 18.0,
                          width: 70.0,
                        ),
                        SizedBox(height: 10),
                        Skeleton(
                          height: 14.0,
                          width: 20.0,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Skeleton(
                          height: 18.0,
                          width: 70.0,
                        ),
                        SizedBox(height: 10),
                        Skeleton(
                          height: 14.0,
                          width: 20.0,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Skeleton(
                          height: 18.0,
                          width: 70.0,
                        ),
                        SizedBox(height: 10),
                        Skeleton(
                          height: 14.0,
                          width: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
