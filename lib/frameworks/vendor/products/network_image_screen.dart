import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_debounce/easy_debounce.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../generated/l10n.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/loading_widget.dart';

class GetNetworkImageScreen extends StatefulWidget {
  const GetNetworkImageScreen({Key? key}) : super(key: key);

  @override
  State<GetNetworkImageScreen> createState() => _StateGetNetworkImage();
}

class _StateGetNetworkImage extends State<GetNetworkImageScreen> {
  late TextEditingController imageNetwork;

  final ValueNotifier<ui.Image?> _imageData = ValueNotifier(null);

  void _onTapUseImage(ui.Image image) async {
    // Get the document directory path
    final appDir = await getTemporaryDirectory();

    // This is the saved image path
    // You can use it to display the saved image later
    final localPath =
        '${appDir.path}/Mobile-${(DateTime.now().millisecondsSinceEpoch)}.png';

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(
        (await (image.toByteData(format: ui.ImageByteFormat.png)))!
            .buffer
            .asUint8List());

    Navigator.of(context).pop(imageFile);
  }

  @override
  void initState() {
    imageNetwork = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    imageNetwork.dispose();
    _imageData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          S.current.imageNetwork,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomTextField(
                    showCancelIcon: true,
                    decoration:
                        InputDecoration(hintText: S.current.pasteYourImageUrl),
                    onCancel: () {
                      _imageData.value = null;
                      imageNetwork.clear();
                    },
                    onChanged: (value) {
                      EasyDebounce.debounce(
                        'imageNetwork',
                        const Duration(milliseconds: 500),
                        () => imageNetwork.text = value,
                      );
                    },
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: imageNetwork,
                    builder: (context, textEditing, child) {
                      final url = textEditing.text;

                      if (url.isEmpty) {
                        return const SizedBox();
                      }

                      return Expanded(
                        child: Container(
                          color: Theme.of(context).colorScheme.background,
                          alignment: Alignment.center,
                          child: ExtendedImage.network(
                            url,
                            key: Key(url),
                            cacheWidth: 640,
                            loadStateChanged: (ExtendedImageState state) {
                              if (state.extendedImageLoadState ==
                                  LoadState.loading) {
                                return const Center(
                                  child: LoadingWidget(),
                                );
                              }
                              if (state.extendedImageLoadState ==
                                  LoadState.failed) {
                                return Center(
                                  child: Text(S.current.failedToLoadImage),
                                );
                              }

                              EasyDebounce.debounce(
                                'load-complete',
                                const Duration(milliseconds: 300),
                                () => _imageData.value =
                                    state.extendedImageInfo?.image,
                              );

                              return state.completedWidget;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ValueListenableBuilder<ui.Image?>(
              valueListenable: _imageData,
              builder: (context, image, child) {
                if (image == null) return const SizedBox();

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _onTapUseImage(image),
                      child: Text(S.current.useThisImage),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
