import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/category/category_model.dart';
import '../../../models/product_model.dart';
import '../../../models/user_model.dart';
import 'widgets/select_image.dart';
import 'widgets/select_info.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  StateCreateProduct createState() => StateCreateProduct();
}

class StateCreateProduct extends State<CreateProductScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Map<String, String?> infoCategory = {};
  List<String> types = ['simple'];
  List<String> typeTranslations = [];
  List<File> fileImages = [];
  List<String> galleryImages = [];
  List<String> networkImages = [];

  TextEditingController? name;
  TextEditingController? description;
  TextEditingController? regularPrice;
  TextEditingController? salePrice;

  String? categorySelected;
  String? typeSelected;
  String? typeTranslationSelected;
  bool isLoading = false;
  bool loadingImage = false;

  void initTranslation() {
    if (typeTranslations.isEmpty) {
      for (var element in types) {
        switch (element) {
          case 'simple':
            typeTranslations.add(S.of(context).simple);
            break;
          case 'grouped':
            typeTranslations.add(S.of(context).grouped);
            break;
          case 'external':
            typeTranslations.add(S.of(context).external);
            break;
          default:
            typeTranslations.add(S.of(context).variable);
        }
      }
    }
  }

  void _createProduct() async {
    if (name!.text.isEmpty) {
      Tools.showSnackBar(_scaffoldMessengerKey.currentState,
          S.of(context).pleaseEnterProductName);
      return;
    }

    if (infoCategory.containsKey(categorySelected) == false) {
      Tools.showSnackBar(_scaffoldMessengerKey.currentState,
          S.of(context).pleaseChooseCategory);
      return;
    }
    if (regularPrice!.text.isEmpty) {
      Tools.showSnackBar(
          _scaffoldMessengerKey.currentState, S.of(context).pleaseAddPrice);
      return;
    }

    setState(() {
      isLoading = true;
      galleryImages = [...galleryImages, ...networkImages];
    });

    final userModel = Provider.of<UserModel>(context, listen: false);
    await Provider.of<ProductModel>(context, listen: false)
        .createProduct(
      galleryImages,
      fileImages,
      userModel.user!.cookie,
      name!.text,
      typeSelected,
      infoCategory[categorySelected],
      salePrice!.text.isNotEmpty ? double.parse(salePrice!.text) : null,
      regularPrice!.text.isNotEmpty ? double.parse(regularPrice!.text) : 0.0,
      description!.text,
    )
        .then((onValue) {
      Tools.showSnackBar(_scaffoldMessengerKey.currentState,
          S.of(context).productCreateReview);
      Future.delayed(const Duration(seconds: 2))
          .then((value) => Navigator.pop(context));
    }).catchError((onError) {
      setState(() {
        isLoading = false;
      });
      Tools.showSnackBar(
          _scaffoldMessengerKey.currentState, onError.toString());
    });
  }

  Widget _renderCategoryOption() {
    var listCategorys = Provider.of<CategoryModel>(context, listen: false);
    return ListenableProvider.value(
      value: listCategorys,
      child: Consumer<CategoryModel>(
        builder: (context, value, child) {
          var categorys = <String?>[];

          if (value.isLoading == false) {
            if (value.categories?.isNotEmpty ?? false) {
              infoCategory.clear();

              for (var cate in value.categories!) {
                categorys.add(cate.name);
                infoCategory[cate.name.toString()] = cate.id;
              }
            }
          }
          return SelectInfo(
            valueSelected: categorySelected,
            data: categorys,
            title: S.of(context).categories,
            hint: S.of(context).chooseCategory,
            onChanged: (cate) {
              setState(() {
                categorySelected = cate;
              });
            },
          );
        },
      ),
    );
  }

  Widget _renderButtonPostProduct() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0.0, top: 4.0),
        child: ElevatedButton(
          onPressed: _createProduct,
          child: Text(S.of(context).postProduct),
        ),
      ),
    );
  }

  Widget _renderPrice() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.of(context).regularPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    width: 1.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                child: TextField(
                  controller: regularPrice,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                S.of(context).salePrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        width: 1.0, color: Theme.of(context).primaryColor)),
                child: TextField(
                  controller: salePrice,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _renderBody() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingImage
                ? S.of(context).waitForLoad
                : S.of(context).waitForPost,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          SpinKitFadingCircle(color: Theme.of(context).primaryColor, size: 50.0)
        ],
      );
    }

    void onSelect(List<File> fileImages) {
      setState(() {
        fileImages = fileImages;
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Text(
                    S.of(context).productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            width: 1.0, color: Theme.of(context).primaryColor),
                        color: Theme.of(context).primaryColorLight),
                    child: TextField(
                      controller: name,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _renderCategoryOption(),
                  const SizedBox(height: 5),
                  SelectInfo(
                    valueSelected: typeTranslationSelected,
                    data: typeTranslations,
                    title: S.of(context).productType,
                    hint: S.of(context).chooseType,
                    onChanged: (type) {
                      setState(() {
                        typeTranslationSelected = type;
                        final index = typeTranslations
                            .indexWhere((element) => element == type);
                        typeSelected = types[index];
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _renderPrice(),
                  const SizedBox(height: 20),
                  SelectImage(
                    fileImages: fileImages,
                    onSelect: onSelect,
                    isLoading: (isLoading) {
                      setState(() {
                        loadingImage = isLoading;
                        isLoading = isLoading;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: TextField(
                          controller: description,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          maxLines: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _renderButtonPostProduct(),
        ],
      ),
    );
  }

  @override
  void initState() {
    name = TextEditingController();
    description = TextEditingController();
    regularPrice = TextEditingController();
    salePrice = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initTranslation();
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            S.of(context).createProduct,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: _renderBody(),
      ),
    );
  }
}
