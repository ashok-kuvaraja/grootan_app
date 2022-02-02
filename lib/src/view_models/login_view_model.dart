import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import '/src/models/user_details.dart';
import '../services/firebase_auth.dart';
import '../services/firebase_store.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel._() {
    initProperties();
  }

  static LoginViewModel instance = LoginViewModel._();

  // To validate a text form fields that exist in the Login Page.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController phoneNumberController, otpController;

  late bool _isCodeSent;
  bool get isCodeSent => _isCodeSent;

  set isCodeSent(bool newValue) {
    if (newValue != isCodeSent) {
      _isCodeSent = newValue;
      if (_isCodeSent) {
        notifyListeners();
      }
    }
  }

  void initProperties() {
    _isCodeSent = false;
    otpController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  Future<void> createUserDetails() async {
    final String userIP = await _findIPAddress();
    final String city = await _findUserLocation();
    final DateTime currentDate = DateTime.now();

    final UserDetails details = UserDetails(
        qrCodeURL: '',
        randomNumber: -1,
        city: city,
        userIP: userIP,
        time: currentDate.toString());

    await FirebaseFireStoreService.instance.addUserDetails(details);
  }

  Future<String> _findIPAddress() async {
    return await http.read(Uri.parse('https://api.ipify.org/'));
  }

  Future<String> _findUserLocation() async {
    LocationData? currentLocation;
    Location location = Location();

    PermissionStatus hasPermission = await location.hasPermission();

    if (hasPermission == PermissionStatus.denied ||
        hasPermission == PermissionStatus.deniedForever) {
      await location.requestPermission();
    }

    if (await location.serviceEnabled()) {
      try {
        currentLocation = await location.getLocation();
      } on PlatformException catch (_) {
        EasyLoading.showInfo('Allow permission to access location',
            duration: const Duration(seconds: 2));
        EasyLoading.dismiss();
        currentLocation = null;
      }
    }

    if (currentLocation != null) {
      List<Placemark> placemark = await placemarkFromCoordinates(
          currentLocation.latitude!, currentLocation.longitude!);
      return placemark.first.locality ?? placemark.first.name ?? '';
    }
    return '';
  }

  Future<void> signOut() async {
    return await FirebaseAuthService.instance.userSignOut();
  }

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild!.unfocus();
      }

      if (!isCodeSent) {
        await FirebaseAuthService.instance.verifyPhoneNumber(
            isResent: false,
            context: context,
            model: this,
            phoneNumber: phoneNumberController.text.trim());
      } else {
        await FirebaseAuthService.instance
            .verifyOTP(context, otpController.text.trim());
      }
    }
  }

  Future<void> showAlertDialog(
      BuildContext context, FirebaseAuthException e) async {
    void handleResendOTPButtonTap() async {
      otpController.clear();
      await FirebaseAuthService.instance.verifyPhoneNumber(
          isResent: true,
          context: context,
          model: this,
          phoneNumber: phoneNumberController.text.trim());
      Navigator.pop(context);
    }

    void handleUpdateNumberButtonTap() {
      otpController.clear();
      isCodeSent = false;
      Navigator.pop(context);
    }

    void handleCancelButtonTap() {
      Navigator.pop(context);
    }

    Widget _buildButton(String title, VoidCallback onTap) {
      return ElevatedButton(
        onPressed: onTap,
        child: Text(title),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.code),
              IconButton(
                  onPressed: handleCancelButtonTap,
                  icon: const Icon(Icons.cancel)),
            ],
          ),
          content: Text(
            e.message ?? 'Sorry! You have entered the invalid OTP.',
          ),
          actions: [
            _buildButton('Resend OTP', handleResendOTPButtonTap),
            _buildButton('Update Number', handleUpdateNumberButtonTap),
          ],
        );
      },
    );
  }
}
