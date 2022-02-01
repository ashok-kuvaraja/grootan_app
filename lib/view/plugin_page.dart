import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

import '../const.dart';
import '../widgets/common.dart';
import '../view_model/plugin_view_model.dart';
import 'last_login_page.dart';

class PluginPage extends StatelessWidget {
  const PluginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PluginViewModel model = PluginViewModel.instance;
    return GrootanAppPage(
      pageTitle: 'PLUGIN',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: FutureBuilder(
            future: model.getLastCheckInTime(),
            builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
              if (snapshot.hasData) {
                return LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: max(constraints.maxHeight, 540.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SpaceProvider(height: 80.0),
                          _buildQRCodeLayer(
                              model, min(constraints.maxWidth, 300.0)),
                          const Spacer(),
                          _buildLastLoginButton(snapshot, context),
                          const SpaceProvider(),
                          _buildSaveButton(model),
                          const SpaceProvider(),
                        ],
                      ),
                    ),
                  );
                });
              } else {
                return const SizedProgressIndicator();
              }
            }),
      ),
    );
  }

  Widget _buildQRCodeLayer(PluginViewModel model, double boxSize) {
    return SizedBox(
      height: boxSize,
      width: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: boxSize / 2,
            width: boxSize,
            height: boxSize / 2,
            child: ClipRRect(
              borderRadius: defaultBorderRadius,
              child: SizedBox(
                width: boxSize / 2,
                height: boxSize / 2,
                child: CustomPaint(
                  painter: PaintGradientBox(boxSize),
                ),
              ),
            ),
          ),
          Positioned(
            child: Column(
              children: [
                RepaintBoundary(
                  key: model.key,
                  child: Container(
                    width: (boxSize / 2) + 30.0,
                    height: (boxSize / 2) + 30.0,
                    decoration: const BoxDecoration(
                        color: Colors.white, borderRadius: defaultBorderRadius),
                    padding: const EdgeInsets.all(15.0),
                    child: SfBarcodeGenerator(
                      symbology: QRCode(),
                      value: model.randomNumber.toString(),
                    ),
                  ),
                ),
                const SpaceProvider(),
                const Text(
                  'Generated Number',
                  style: TextStyle(color: defaultTextColor, fontSize: 20.0),
                ),
                const SpaceProvider(),
                Text(
                  model.randomNumber.toString(),
                  style:
                      const TextStyle(color: defaultTextColor, fontSize: 30.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastLoginButton(
      AsyncSnapshot<Object?> snapshot, BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: OutlinedButton(
          child: Text(
            "Last login at Today, ${snapshot.data}",
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LastLoginPage()),
            );
          },
          style: ButtonStyle(
            side: MaterialStateProperty.resolveWith((states) {
              return const BorderSide(color: Colors.grey, width: 2);
            }),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
              return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(PluginViewModel model) {
    return RoundedButton(
      child: const Text('SAVE'),
      onPressed: () async {
        await model.updateUserDetails();
      },
    );
  }
}

class PaintGradientBox extends CustomPainter {
  PaintGradientBox(this.boxWidth);

  final double boxWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Size boxSize = Size(boxWidth, boxWidth / 2);
    double boxMidWidth = boxSize.width / 2;
    double boxMidHeight = boxSize.height / 2;
    double viewMidWidth = size.width / 2;
    double viewMidHeight = size.height / 2;

    Paint paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(viewMidWidth - boxMidWidth, viewMidHeight - boxMidHeight);
    path.lineTo(viewMidWidth + boxMidWidth, viewMidHeight - boxMidHeight);
    path.lineTo(viewMidWidth + boxMidWidth, viewMidHeight + boxMidHeight);
    path.close();

    canvas.drawPath(path, paint);

    paint = Paint()
      ..color = tileBackgroundColor
      ..style = PaintingStyle.fill;

    path.reset();
    path.moveTo(viewMidWidth - boxMidWidth, viewMidHeight - boxMidHeight);
    path.lineTo(viewMidWidth - boxMidWidth, viewMidHeight + boxMidHeight);
    path.lineTo(viewMidWidth + boxMidWidth, viewMidHeight + boxMidHeight);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
