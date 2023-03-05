import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../models/cart/cart_base.dart';
import '../../../models/entities/order_delivery_date.dart';

class DeliveryDropbox extends StatefulWidget {
  final List<OrderDeliveryDate> dates;
  final String storeId;
  final Function onCallBack;
  const DeliveryDropbox(
      {Key? key,
      required this.dates,
      required this.onCallBack,
      required this.storeId})
      : super(key: key);

  @override
  State<DeliveryDropbox> createState() => _DeliveryDropboxState();
}

class _DeliveryDropboxState extends State<DeliveryDropbox> {
  var _currentSelectedDate;

  @override
  void initState() {
    _currentSelectedDate = widget.dates.first;
    Provider.of<CartModel>(context, listen: false)
        .setOrderDeliveryDateByStoreId(_currentSelectedDate, widget.storeId);
    super.initState();
  }

  void _update(OrderDeliveryDate? date) {
    _currentSelectedDate = date;
    setState(() {});
    widget.onCallBack(_currentSelectedDate);
  }

  @override
  Widget build(BuildContext context) {
    if (isIos) {
      return _buildDropDownIos();
    }
    return _buildDropDownAndroid();
  }

  Widget _buildDropDownIos() {
    return InkWell(
      onTap: _showIOSDropDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0)),
        child: Text(
          _currentSelectedDate.deliveryDate,
        ),
      ),
    );
  }

  void _showIOSDropDown() {
    var index = widget.dates.indexWhere(
        (element) => element.timeStamp == _currentSelectedDate.timeStamp);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: (context),
      builder: (_) => Container(
        height: 200,
        color: Theme.of(context).colorScheme.background,
        child: CupertinoPicker(
          scrollController: FixedExtentScrollController(initialItem: index),
          itemExtent: 30,
          onSelectedItemChanged: (val) {
            _update(widget.dates[val]);
          },
          children: List.generate(
            widget.dates.length,
            (index) => Center(
              child: Text(
                widget.dates[index].deliveryDate!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropDownAndroid() {
    return DropdownButton<OrderDeliveryDate>(
        value: _currentSelectedDate,
        elevation: 16,
        style: Theme.of(context).textTheme.titleMedium,
        onChanged: _update,
        items: List.generate(widget.dates.length, (index) {
          return DropdownMenuItem<OrderDeliveryDate>(
            value: widget.dates[index],
            child: Text(
              widget.dates[index].deliveryDate!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }));
  }
}
