import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:share/share.dart';

import '../../../../common/tools.dart';
import '../../../../models/vendor/store_model.dart';

class Contact extends StatelessWidget {
  final Store store;

  const Contact({
    required this.store,
  });

  Map<String, dynamic> get contactDetails => <String, dynamic>{
        if (isNotBlank(store.address) && store.showAddress)
          'address': {
            'icon': CupertinoIcons.placemark_fill,
            'title': store.address,
          },
        if (isNotBlank(store.email) && store.showEmail)
          'email': {
            'icon': CupertinoIcons.mail_solid,
            'title': store.email,
            'url': 'mailto:${store.email}',
          },
        if (isNotBlank(store.phone) && store.showPhone)
          'phone': {
            'icon': CupertinoIcons.phone_fill,
            'title': store.phone,
            'url': 'tel:${store.phone}',
          },
        if (isNotBlank(store.website))
          'website': {
            'icon': CupertinoIcons.globe,
            'title': store.website,
            'url': store.website,
          },
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final key in contactDetails.keys)
          ListTile(
            leading: Icon(contactDetails[key]['icon']),
            title: Text(contactDetails[key]['title']),
            onTap: () async {
              if (contactDetails[key].containsKey('url')) {
                await Tools.launchURL(contactDetails[key]['url']);
              } else {
                await Share.share(contactDetails[key]['title']);
              }
            },
          ),
        ...renderSocials(),
      ],
    );
  }

  List<Widget> renderSocials() {
    if (store.socials != null && store.socials!.keys.isNotEmpty) {
      var items = <Widget>[];
      for (var key in store.socials!.keys) {
        if (store.socials![key] != null && store.socials![key]!.isNotEmpty) {
          items.add(
            ListTile(
              title: Text(key),
              subtitle: store.socials?[key] != null
                  ? Text(store.socials?[key] ?? '')
                  : null,
              onTap: () async {
                final url = store.socials![key]!;
                await Tools.launchURL(url);
              },
            ),
          );
        }
      }
      return items;
    }
    return [];
  }
}
