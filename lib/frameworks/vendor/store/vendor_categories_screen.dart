import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../routes/flux_navigate.dart';
import '../../../screens/categories/layouts/side_menu_with_group.dart';
import '../../../screens/common/app_bar_mixin.dart';
import '../../../screens/index.dart'
    show
        CardCategories,
        ColumnCategories,
        GridCategory,
        SideMenuCategories,
        SideMenuSubCategories,
        SubCategories;
import '../../../widgets/cardlist/index.dart';
import 'store_screen.dart';

class VendorCategoriesScreen extends StatefulWidget {
  final String? layout;
  final bool enableParallax;
  final double? parallaxImageRatio;

  const VendorCategoriesScreen({
    Key key = const Key('category'),
    this.layout,
    this.enableParallax = false,
    this.parallaxImageRatio,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<VendorCategoriesScreen>
    with AutomaticKeepAliveClientMixin, AppBarMixin {
  @override
  bool get wantKeepAlive => true;

  final _pageController = PageController(initialPage: 2);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(0);
    });
    screenScrollController = _scrollController;
  }

  Future<void> _requestLocationPermission() async {
    final location = Location();

    /// ask location permission
    var isGranted = await location.hasPermission();
    if (isGranted == PermissionStatus.denied) {
      isGranted = await location.requestPermission();
      if (isGranted != PermissionStatus.granted) {
        return;
      }
    }

    /// ask location service
    var isAllowService = await location.serviceEnabled();
    if (!isAllowService) {
      isAllowService = await location.requestService();
      if (!isAllowService) {
        return;
      }
    }

    unawaited(FluxNavigate.pushNamed(RouteList.map));
  }

  void _onChangeTab(value) {
    _pageController.animateToPage(
      value!,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return renderScaffold(
      resizeToAvoidBottomInset: false,
      routeName: RouteList.vendorCategory,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 8),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              elevation: 0,
              centerTitle: true,
              title: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 250,
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      return CupertinoSlidingSegmentedControl<int>(
                        backgroundColor: Theme.of(context).primaryColorLight,
                        thumbColor: Theme.of(context).colorScheme.background,
                        children: {
                          0: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              S.of(context).stores.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.fontFamily,
                              ),
                            ),
                          ),
                          1: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              S.of(context).categories.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                                fontFamily: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.fontFamily,
                              ),
                            ),
                          ),
                        },
                        onValueChanged: _onChangeTab,
                        groupValue: _pageController.hasClients
                            ? _pageController.page!.round()
                            : 0,
                      );
                    },
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: _requestLocationPermission,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Icon(
                        Icons.place,
                        size: 26,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              allowImplicitScrolling: true,
              children: [
                StoreScreen(),
                renderCategories(
                  widget.layout,
                  widget.enableParallax,
                  widget.parallaxImageRatio,
                  _scrollController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderCategories(
    String? layout,
    bool enableParallax,
    double? parallaxImageRatio,
    ScrollController? scrollController,
  ) {
    switch (layout) {
      case CardCategories.type:
        return CardCategories(
          enableParallax: enableParallax,
          parallaxImageRatio: parallaxImageRatio,
          scrollController: scrollController,
        );
      case ColumnCategories.type:
        return ColumnCategories(
          scrollController: scrollController,
        );
      case SubCategories.type:
        return SubCategories(
          scrollController: scrollController,
        );
      case SideMenuCategories.type:
        return const SideMenuCategories();
      case SideMenuSubCategories.type:
        return const SideMenuSubCategories();
      case SideMenuGroupCategories.type:
        return const SideMenuGroupCategories();
      case GridCategory.type:
        return GridCategory(
          scrollController: scrollController,
        );
      case HorizonMenu.type:
      default:
        return const HorizonMenu();
    }
  }
}
