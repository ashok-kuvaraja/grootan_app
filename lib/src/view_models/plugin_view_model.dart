import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/firebase_store.dart';

class PluginViewModel {
  static PluginViewModel instance = PluginViewModel._();

  PluginViewModel._() {
    initProperties();
  }

  late int randomNumber;

  // Provides a `GlobalKey` to covert a QR code to Image.
  GlobalKey key = GlobalKey();

  void initProperties() {
    _generateRandomNumber();
  }

  Future<void> updateUserDetails() async {
    EasyLoading.show(status: 'Saving');
    final String qrCodeLink = await _getQRDownloadLink();

    await FirebaseFireStoreService.instance
        .updateUser(qrCodeLink, randomNumber);
  }

  void _generateRandomNumber() {
    Random random = Random();
    randomNumber = 10000 + random.nextInt(89999);
  }

  Future<String> getLastCheckInTime() async {
    return await FirebaseFireStoreService.instance.getLastCheckInTime();
  }

  Future<String> _getQRDownloadLink() async {
    final RenderRepaintBoundary boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final Directory tempDir = await getTemporaryDirectory();
    final File file = await File('${tempDir.path}/$randomNumber.png').create();
    await file.writeAsBytes(pngBytes);

    try {
      final reference =
          FirebaseStorage.instance.ref('QRCodes/$randomNumber.png');

      UploadTask task = reference.putFile(file);
      final snapshot = await task.whenComplete(() {});

      return await snapshot.ref.getDownloadURL();
    } on Exception catch (_) {
      return '';
    }
  }
}
