import 'package:flutter/material.dart';

class MapAddressSearchWidget extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function? onChangedCallBack;
  final Function? onSubmittedCallBack;
  const MapAddressSearchWidget(
      {Key? key,
      this.focusNode,
      this.controller,
      this.onChangedCallBack,
      this.onSubmittedCallBack})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        hintText: 'Search address...',
        hintStyle: const TextStyle(fontSize: 14.0),
        fillColor: Theme.of(context).cardColor,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          borderSide: BorderSide.none,
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
          borderSide: BorderSide.none,
        ),
      ),
      //controller: model.searchController,
      onChanged: onChangedCallBack as void Function(String)?,
      onSubmitted: onSubmittedCallBack as void Function(String)?,
    );
  }
}
