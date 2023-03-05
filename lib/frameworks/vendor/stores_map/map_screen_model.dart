import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

import '../../../common/config.dart';
import '../../../models/entities/prediction.dart';
import '../../../models/vendor/store_model.dart';
import '../../../services/index.dart';

enum ViewState { init, loading, loaded }

class MapModel extends ChangeNotifier {
  ViewState viewState = ViewState.loading;
  final Services _services = Services();
  List<Store> listStore = [];
  LocationData? userLocation;
  List<Prediction> autocompletePlaces = [];
  final TextEditingController addressController = TextEditingController();
  final FocusNode addressFocusNode = FocusNode();
  Set<Marker> markers = <Marker>{};
  late GoogleMapController mapController;
  var uuid;
  final kZoom = 16.0;

  void setState(ViewState state) {
    viewState = state;
    notifyListeners();
  }

  MapModel() {
    getUserLocation().then((value) {
      getListStore(lang: 'en', page: 1);
    });
    uuid = const Uuid().v4();
  }

  Future<void> getUserLocation() async {
    var location = Location();
    userLocation = await location.getLocation();
  }

  void getListStore({lang, page}) async {
    setState(ViewState.loading);

    final predictionVal = Prediction();
    predictionVal.lat = userLocation!.latitude.toString();
    predictionVal.long = userLocation!.longitude.toString();
    listStore = await _services.api.getNearbyStores(predictionVal)!;

    /// Check null in case of forgetting to add this attribute on future releases.
    if (kVendorConfig.showAllVendorMarkers) {
      markers.clear();
      if (listStore.isNotEmpty) {
        for (var store in listStore) {
          markers.add(
            Marker(
              markerId: MarkerId(store.id.toString()),
              infoWindow: InfoWindow(
                  title: store.name, snippet: store.address, onTap: () {}),
              position: LatLng(
                store.lat!,
                store.long!,
              ),
            ),
          );
        }
      }

      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(double.parse(predictionVal.lat!),
                double.parse(predictionVal.long!)),
            zoom: kZoom)),
      );
    } else {
      if (listStore.isNotEmpty) {
        markers.add(
          Marker(
            markerId: MarkerId(listStore[0].id.toString()),
            infoWindow: InfoWindow(
                title: listStore[0].name,
                snippet: listStore[0].address,
                onTap: () {}),
            position: LatLng(
              listStore[0].lat!,
              listStore[0].long!,
            ),
          ),
        );

        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(listStore[0].lat!, listStore[0].long!),
              zoom: kZoom)),
        );
      }
    }

    setState(ViewState.loaded);

//
//    List<Store> stores = await _services.searchStores(page: page);
//    List<Store> lstStores = [];
//    stores.forEach((store) {
//      if (store.long != null && store.lat != null) {
//        lstStores.add(store);
//      }
//    });
//    listStore = lstStores;
  }

  void getAutocompletePlaces() {
    EasyDebounce.cancel('getAutocompletePlaces');
    EasyDebounce.debounce(
        'getAutocompletePlaces', const Duration(milliseconds: 300), () async {
      if (addressController.text != '') {
        autocompletePlaces = await _services.api
            .getAutoCompletePlaces(addressController.text, uuid)!;
        setState(ViewState.loaded);
      }
    });
  }

  void getLocationFromPlace(int index) async {
    final prediction = autocompletePlaces[index];
    autocompletePlaces.clear();
    addressFocusNode.unfocus();
    setState(ViewState.loading);
    addressController.text = prediction.description!;
    final predictionVal = await _services.api.getPlaceDetail(prediction, uuid)!;

    uuid = const Uuid().v4();
    listStore = await _services.api.getNearbyStores(predictionVal)!;

    if (kVendorConfig.showAllVendorMarkers) {
      markers.clear();
      if (listStore.isNotEmpty) {
        for (var store in listStore) {
          markers.add(
            Marker(
              markerId: MarkerId(store.id.toString()),
              infoWindow: InfoWindow(
                  title: store.name, snippet: store.address, onTap: () {}),
              position: LatLng(
                store.lat!,
                store.long!,
              ),
            ),
          );
        }
      }
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(double.parse(predictionVal.lat!),
                double.parse(predictionVal.long!)),
            zoom: kZoom)),
      );
    } else {
      if (listStore.isNotEmpty) {
        markers.add(
          Marker(
            markerId: MarkerId(listStore[0].id.toString()),
            infoWindow: InfoWindow(
                title: listStore[0].name,
                snippet: listStore[0].address,
                onTap: () {}),
            position: LatLng(
              listStore[0].lat!,
              listStore[0].long!,
            ),
          ),
        );
        await mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: LatLng(listStore[0].lat!, listStore[0].long!),
              zoom: kZoom)),
        );
      }
    }

    setState(ViewState.loaded);
  }
}
