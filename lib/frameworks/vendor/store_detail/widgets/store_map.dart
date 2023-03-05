import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../common/config.dart';
import '../../../../common/constants.dart';
import '../../../../common/tools.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/vendor/store_model.dart';
import '../../../../screens/base_screen.dart';
import '../../../../screens/common/google_map_mixin.dart';
import '../../../../widgets/common/index.dart';

class StoreMap extends StatefulWidget {
  final Store? store;
  final bool static;

  const StoreMap({this.store, this.static = true});

  @override
  BaseScreen<StoreMap> createState() => _StoreMapState();
}

class _StoreMapState extends BaseScreen<StoreMap> with GoogleMapMixin {
  GoogleMapController? pageController;
  Uri? renderMapURL;

  @override
  void afterFirstLayout(BuildContext context) {
    _buildUrl();
  }

  void _buildUrl() {
    // this should change to your own Google API key
    var googleMapsApiKey;
    if (isIos) {
      googleMapsApiKey = kGoogleApiKey.ios;
    } else if (isAndroid) {
      googleMapsApiKey = kGoogleApiKey.android;
    } else {
      googleMapsApiKey = kGoogleApiKey.web;
    }

    renderMapURL = Uri(
      scheme: 'https',
      host: 'maps.googleapis.com',
      port: 443,
      path: '/maps/api/staticmap',
      queryParameters: {
        'size': '800x600',
        'center': '${widget.store!.lat},${widget.store!.long}',
        'zoom': '13',
        'maptype': 'roadmap',
        'markers':
            'color:red|label:C|${widget.store!.lat},${widget.store!.long}',
        'key': '$googleMapsApiKey',
        'style': getMapStyleParams(),
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop || kIsWeb) {
      return const SizedBox();
    }
    if (widget.store!.lat == null || widget.store!.long == null) {
      return const SizedBox();
    }

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          if (renderMapURL != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Tools.launchMapsURL(
                  widget.store!.lat,
                  widget.store!.long,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FluxImage(
                    imageUrl: renderMapURL.toString(),
                    fit: BoxFit.cover,
                    // width: double.infinity,
                    errorWidget: Center(
                      child: Text(
                        S.of(context).viewOnGoogleMaps,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => Tools.launchMapsURL(
                widget.store!.lat,
                widget.store!.long,
              ),
              child: Container(
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(width: 5),
                    Icon(
                      Icons.directions,
                      color: Theme.of(context).primaryColor,
                      size: 25,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(S.of(context).direction),
                    const SizedBox(width: 10),
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
