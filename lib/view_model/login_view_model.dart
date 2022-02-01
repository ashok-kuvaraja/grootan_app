import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;

import '../model/user_details.dart';
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

    await FirebaseFireStoreService.instance.createUser(details);
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
        EasyLoading.showInfo('Please enable the location',
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
    return await FirebaseAuthService.instance.signOut();
  }

  Future<void> onSubmit(BuildContext context) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild!.unfocus();
      }

      if (!isCodeSent) {
        await FirebaseAuthService.instance.verifyPhoneNumber(
            model: this, phoneNumber: phoneNumberController.text.trim());
      } else {
        await FirebaseAuthService.instance
            .verifyOTP(context, otpController.text.trim());
      }
    }
  }
}
