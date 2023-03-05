import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../network_image_screen.dart';

class SelectImage extends StatelessWidget {
  final Function(List<File>)? onSelect;
  final Function(bool isLoading)? isLoading;
  final List<File> fileImages;

  // final List<String>? networkImages;

  const SelectImage({
    Key? key,
    this.onSelect,
    this.isLoading,
    required this.fileImages,
    // this.networkImages,
  }) : super(key: key);

  Future _getImageFromCamera() async {
    isLoading!(true);
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      isLoading!(false);
      return;
    }

    var image = File(pickedFile.path);

    var path = image.path;
    var imageDecode = img.decodeImage(image.readAsBytesSync());

    path = '${path.substring(0, path.lastIndexOf('.'))}.png';
    await image.rename(path).then((onValue) {
      onValue.writeAsBytesSync(img.encodePng(imageDecode!));
      fileImages.add(onValue);
    });
    onSelect!(fileImages);
    isLoading!(false);
  }

  Future _getImageFromGallery() async {
    isLoading!(true);
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (pickedFile == null) {
      isLoading!(false);
      return;
    }

    var image = File(pickedFile.path);

    if (isIos) {
      var path = image.path;
      var imageDecode = img.decodeImage(image.readAsBytesSync());

      path = '${path.substring(0, path.lastIndexOf('.'))}.png';
      await image.rename(path).then((onValue) {
        onValue.writeAsBytesSync(img.encodePng(imageDecode!));
        fileImages.add(onValue);
      });
    } else {
      fileImages.add(image);
    }
    onSelect!(fileImages);
    isLoading!(false);
  }

  void _getNetworkImage(BuildContext context) async {
    isLoading!(true);
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GetNetworkImageScreen(),
        )).then((result) {
      if (result != null) {
        fileImages.add(result);
        onSelect!(fileImages);
        // setState(() {});
      }
    });
    isLoading!(false);
  }

  void _showOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.only(bottom: 150, left: 20, right: 20, top: 20),
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
                child: Column(
                  children: const <Widget>[
                    Icon(
                      Icons.image,
                      size: 60,
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
                child: Column(
                  children: const <Widget>[
                    Icon(
                      Icons.camera_alt,
                      size: 60,
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getNetworkImage(context);
                },
                child: Column(
                  children: const <Widget>[
                    Icon(
                      Icons.broken_image,
                      size: 60,
                    ),
                    Text(
                      'Network',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _renderListImage() {
    return List.generate(
      fileImages.length,
      (index) {
        Widget image;
        var onTapClose;

        image = Image.file(
          fileImages[index],
        );

        onTapClose = () {
          fileImages.removeAt(index);
          onSelect!(fileImages);
        };

        return Container(
          margin: const EdgeInsets.only(right: 10),
          child: Stack(
            children: <Widget>[
              image,
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap: onTapClose,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Text(
              S.of(context).imageGallery,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            )),
            const SizedBox(width: 30),
            ElevatedButton(
              onPressed: () {
                _showOption(context);
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        if (fileImages.isNotEmpty)
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColorLight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _renderListImage()),
            ),
          ),
        if (fileImages.isEmpty)
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColorLight,
            alignment: AlignmentDirectional.center,
            child: Text(
              S.of(context).addingYourImage,
              style: const TextStyle(fontWeight: FontWeight.w200),
            ),
          )
      ],
    );
  }
}
