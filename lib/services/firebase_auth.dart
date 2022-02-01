import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../view/plugin_page.dart';
import '../view_model/login_view_model.dart';
import '../view_model/plugin_view_model.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _verificationID = '';

  String get currentUserID => _firebaseAuth.currentUser?.uid ?? '';

  Future<void> verifyPhoneNumber(
      {required String phoneNumber, required LoginViewModel model}) async {
    model.isCodeSent = false;
    void onCodeSent(String verificationId, int? forceResendingToken) {
      _verificationID = verificationId;
      model.isCodeSent = true;
      EasyLoading.showSuccess('OTP has been sent successfully');
      EasyLoading.dismiss();
    }

    void onVerificationFailed(FirebaseAuthException exception) {
      EasyLoading.showError('Verfication failed');
      EasyLoading.dismiss();
    }

    void onVerificationCompleted(PhoneAuthCredential credential) {
      EasyLoading.showSuccess('Verfication completed');
      EasyLoading.dismiss();
    }

    EasyLoading.show(status: 'Verifing phone number');

    await _firebaseAuth.verifyPhoneNumber(
        codeSent: onCodeSent,
        phoneNumber: "+91$phoneNumber",
        timeout: const Duration(seconds: 100),
        verificationFailed: onVerificationFailed,
        verificationCompleted: onVerificationCompleted,
        codeAutoRetrievalTimeout: (String verificationId) {});
  }

  Future<void> verifyOTP(BuildContext context, String otp) async {
    try {
      EasyLoading.show(status: 'Verifing OTP');
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(PhoneAuthProvider.credential(
              verificationId: _verificationID, smsCode: otp));

      if (userCredential.user != null) {
        await LoginViewModel.instance.createUserDetails();

        EasyLoading.showSuccess('Log in successfully!');
        EasyLoading.dismiss();

        PluginViewModel.instance.initProperties();

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const PluginPage()));
      } else {
        EasyLoading.showError("User doesn't exist");
        EasyLoading.dismiss();
      }
    } on Exception catch (_) {
      EasyLoading.showError('Invalid Credential');
      EasyLoading.dismiss();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
