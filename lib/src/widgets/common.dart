import 'package:flutter/material.dart';

import '/src/view_models/login_view_model.dart';
import '/src/views/login_page.dart';
import '../const.dart';

class GrootanAppPage extends StatelessWidget {
  const GrootanAppPage({Key? key, required this.child, required this.pageTitle})
      : super(key: key);

  final Widget child;

  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constrains) {
          return SizedBox.fromSize(
            size: constrains.biggest,
            child: Stack(
              children: [
                _paintBackgroundColor(),
                if (pageTitle == 'Last Login') _buildBackButton(context),
                _buildLogoutHolder(),
                if (pageTitle != 'LOGIN') _buildLogoutButton(context),
                _buildBody(constrains.biggest),
                _buildPageTitle(constrains.biggest)
              ],
            ),
          );
        }),
      ),
    );
  }

  Positioned _paintBackgroundColor() =>
      const Positioned.fill(child: ColoredBox(color: primaryColor));

  Positioned _buildBackButton(BuildContext context) {
    void onTap() => Navigator.of(context).pop();

    return Positioned(
      top: 20.0,
      left: 25.0,
      child: InkWell(
        onTap: onTap,
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
        ),
      ),
    );
  }

  Positioned _buildLogoutHolder() {
    return Positioned(
      top: -60.0,
      right: -20.0,
      child: Container(
        width: 150.0,
        height: 150.0,
        decoration: const BoxDecoration(
          color: secondaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    void onTap() async => await showLogoutPopup(context);
    return Positioned(
      top: 20.0,
      right: 25.0,
      child: InkWell(
        onTap: onTap,
        child: const Text(
          'Logout',
          style: TextStyle(
            color: defaultTextColor,
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  Positioned _buildBody(Size viewSize) {
    return Positioned(
      left: 0.0,
      top: 90.0,
      child: Container(
        decoration: const BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        width: viewSize.width,
        height: viewSize.height - 90.0,
        child: child,
      ),
    );
  }

  Positioned _buildPageTitle(Size viewSize) {
    return Positioned(
      top: 75.0,
      left: (viewSize.width / 2) - 90.0,
      child: Container(
        width: 180.0,
        height: 50.0,
        decoration: BoxDecoration(
            color: pageTitleBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            shape: BoxShape.rectangle),
        child: Center(
          child: Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 24.0,
              color: defaultTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Future showLogoutPopup(BuildContext context) async {
    void handleOkButtonTap() async {
      await LoginViewModel.instance.signOut();
      Navigator.pop(context);
      LoginViewModel.instance.initProperties();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (predicate) => false);
    }

    void handleCancelButtonTap() => Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('LOG OUT'),
          content: const Text('Would you like to log out?'),
          actions: [
            ElevatedButton(
              onPressed: handleOkButtonTap,
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: handleCancelButtonTap,
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({Key? key, required this.onPressed, required this.child})
      : super(key: key);

  final VoidCallback onPressed;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50.0,
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color?>(buttonBackgroundColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: defaultBorderRadius)),
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}

class SpaceProvider extends SizedBox {
  const SpaceProvider({Key? key, double height = 20.0})
      : super(key: key, height: height);
}

class SizedProgressIndicator extends StatelessWidget {
  const SizedProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 25.0,
        height: 25.0,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
