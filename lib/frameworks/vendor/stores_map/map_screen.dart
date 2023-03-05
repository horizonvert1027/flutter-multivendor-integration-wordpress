import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inspireui/inspireui.dart' show PlatformError, Skeleton;
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/vendor/store_model.dart';
import '../../../screens/common/app_bar_mixin.dart';
import '../../../screens/common/google_map_mixin.dart';
import 'map_screen_model.dart';
import 'store_banner.dart';
import 'widgets/map_address_search_widget.dart';

/// Map Screen
class MapScreen extends StatefulWidget {
  const MapScreen();

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AppBarMixin, GoogleMapMixin {
  final kDefaultZoom = 16.0;

  void _onMapCreated(GoogleMapController controller, MapModel mapModel) async {
    mapModel.mapController = controller;
    await setMapStyle(controller);
  }

  void _moveToStore(Store store, MapModel mapModel) {
    mapModel.mapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(store.lat!, store.long!), zoom: kDefaultZoom)),
    );
  }

  Future<bool> requestLocation() async {
    var location = Location();

    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    var allow = await location.hasPermission();
    if (allow == PermissionStatus.denied) {
      allow = await location.requestPermission();
      if (allow != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  void _moveToMyLocation(MapModel mapModel) {
    requestLocation();
    if (mapModel.userLocation != null) {
      mapModel.mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(mapModel.userLocation!.latitude!,
                mapModel.userLocation!.longitude!),
            zoom: kDefaultZoom)),
      );
    }
  }

  Widget _buildCarousel(double width, List<Store> stores, MapModel mapModel) {
    if (stores.isEmpty) {
      return Container();
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: width,
        height: width * 0.5,
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Swiper(
          key: const Key('vendors'),
          loop: false,
          viewportFraction: 0.6,
          scale: 0.8,
          itemBuilder: (context, index) {
            final store = stores[index];
            if (store.lat == null || store.long == null) {
              return const SizedBox();
            }
            return StoreBanner(
              store: stores[index],
              width: width,
              moveToStore: () => _moveToStore(store, mapModel),
            );
          },
          itemCount: stores.length,
          onIndexChanged: (index) {
            if (!kVendorConfig.showAllVendorMarkers) {
              mapModel.markers.clear();
              mapModel.markers.add(Marker(
                  markerId: MarkerId('${stores[index].id}'),
                  infoWindow:
                      InfoWindow(title: stores[index].name, onTap: () {}),
                  position: LatLng(stores[index].lat!, stores[index].long!)));
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCarousel(width) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: width,
        height: width * 0.5,
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        child: Swiper(
          key: const Key('empty'),
          loop: false,
          viewportFraction: 0.6,
          scale: 0.8,
          itemBuilder: (context, index) {
            return Skeleton(
              width: width * 0.2,
              height: width * 0.5,
            );
          },
          itemCount: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;
    if (!isMobile) {
      return const PlatformError();
    }

    return LayoutBuilder(builder: (context, constraints) {
      var width = constraints.maxWidth;
      return renderScaffold(
        disableSafeArea: true,
        routeName: RouteList.map,
        resizeToAvoidBottomInset: false,
        child: ChangeNotifierProvider<MapModel>(
          create: (context) => MapModel(),
          child: Consumer<MapModel>(
            builder: (context, mapModel, _) {
              switch (mapModel.viewState) {
                case ViewState.loaded:
                  return Stack(
                    children: <Widget>[
                      if (mapModel.userLocation != null)
                        SizedBox(
                          width: width,
                          height: MediaQuery.of(context).size.height,
                          child: GoogleMap(
                            zoomControlsEnabled: true,
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                mapModel.userLocation!.latitude!,
                                mapModel.userLocation!.longitude!,
                              ),
                              zoom: kDefaultZoom,
                            ),
                            onMapCreated: (controller) =>
                                _onMapCreated(controller, mapModel),
                            markers: mapModel.markers,
                          ),
                        ),
                      if (mapModel.listStore.isNotEmpty)
                        _buildCarousel(
                          constraints.maxWidth,
                          mapModel.listStore,
                          mapModel,
                        ),
                      SafeArea(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            if (canPop)
                              InkWell(
                                onTap: Navigator.of(context).pop,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    height: 35.0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MapAddressSearchWidget(
                                            controller:
                                                mapModel.addressController,
                                            focusNode:
                                                mapModel.addressFocusNode,
                                            onChangedCallBack: (val) {
                                              mapModel.getAutocompletePlaces();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                      ],
                                    ),
                                  ),
                                  if (mapModel.autocompletePlaces.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 5.0, left: 20, right: 70.0),
                                      padding: const EdgeInsets.all(
                                        10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).colorScheme.background,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: List.generate(
                                            mapModel.autocompletePlaces.length,
                                            (index) => InkWell(
                                                  onTap: () => mapModel
                                                      .getLocationFromPlace(
                                                          index),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons
                                                          .location_on_rounded),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Text(
                                                          mapModel
                                                              .autocompletePlaces[
                                                                  index]
                                                              .description!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(20.0),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _moveToMyLocation(mapModel),
                            icon: const Icon(
                              Icons.my_location_sharp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );

                case ViewState.loading:
                  return Stack(
                    children: <Widget>[
                      SizedBox(
                        width: width,
                        height: MediaQuery.of(context).size.height,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          zoomControlsEnabled: true,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                mapModel.userLocation == null
                                    ? 0.0
                                    : mapModel.userLocation!.latitude!,
                                mapModel.userLocation == null
                                    ? 0.0
                                    : mapModel.userLocation!.longitude!,
                              ),
                              zoom: kDefaultZoom),
                          onMapCreated: (controller) =>
                              _onMapCreated(controller, mapModel),
                        ),
                      ),
                      _buildEmptyCarousel(width),
                      SafeArea(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 10),
                            if (canPop)
                              InkWell(
                                onTap: Navigator.of(context).pop,
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 3.0, left: 5.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    height: 35.0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: MapAddressSearchWidget(
                                            controller:
                                                mapModel.addressController,
                                            focusNode:
                                                mapModel.addressFocusNode,
                                            onChangedCallBack: (val) {
                                              mapModel.getAutocompletePlaces();
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                default:
                  return Container(
                    width: width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey,
                  );
              }
            },
          ),
        ),
      );
    });
  }
}
