import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '/src/views/plugin_page.dart';
import '/src/view_models/login_view_model.dart';
import '/src/view_models/plugin_view_model.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  int? _resendToken;

  String _verificationID = '';

  String get currentUserID => _firebaseAuth.currentUser?.uid ?? '';

  Future<void> verifyPhoneNumber(
      {required BuildContext context,
      required bool isResent,
      required String phoneNumber,
      required LoginViewModel model}) async {
    if (model.isCodeSent) {
      model.isCodeSent = false;
    }

    void onCodeSent(String verificationId, int? forceResendingToken) {
      _verificationID = verificationId;
      if (!isResent) {
        _resendToken = forceResendingToken;
      }
      model.isCodeSent = true;
      EasyLoading.showSuccess('OTP has been sent successfully');
      EasyLoading.dismiss();
    }

    void onVerificationFailed(FirebaseAuthException e) {
      EasyLoading.dismiss();
      LoginViewModel.instance.showAlertDialog(context, e);
    }

    void onVerificationCompleted(PhoneAuthCredential credential) async {
      try {
        await _firebaseAuth.signInWithCredential(credential);
        EasyLoading.showSuccess('Verfication completed');
        EasyLoading.dismiss();
      } on Exception catch (_) {
        return;
      }
    }

    EasyLoading.show(status: 'Verifing phone number');

    await _firebaseAuth.verifyPhoneNumber(
        codeSent: onCodeSent,
        phoneNumber: "+91$phoneNumber",
        forceResendingToken: isResent ? _resendToken : null,
        timeout: const Duration(minutes: 1),
        verificationFailed: onVerificationFailed,
        verificationCompleted: onVerificationCompleted,
        codeAutoRetrievalTimeout: (_) {});
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
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      LoginViewModel.instance.showAlertDialog(context, e);
    }
  }

  Future<void> userSignOut() async {
    await _firebaseAuth.signOut();
  }
}
