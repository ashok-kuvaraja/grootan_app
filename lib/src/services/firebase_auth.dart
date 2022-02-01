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

  String _verificationID = '';

  int? _resendToken;

  String get currentUserID => _firebaseAuth.currentUser?.uid ?? '';

  Future<void> verifyPhoneNumber(
      {required String phoneNumber, required LoginViewModel model}) async {
    if (model.isCodeSent) {
      model.isCodeSent = false;
    }

    void onCodeSent(String verificationId, int? forceResendingToken) {
      _verificationID = verificationId;
      _resendToken = forceResendingToken;
      model.isCodeSent = true;
      EasyLoading.showSuccess('OTP has been sent successfully');
      EasyLoading.dismiss();
    }

    void onVerificationFailed(FirebaseAuthException e) {
      EasyLoading.showError('${e.code}. Please try again');
      model.isCodeSent = false;
      EasyLoading.dismiss();
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

    void onTimeOut(String verificationID) async {
      if (currentUserID.isNotEmpty) {
        EasyLoading.showError('Time out. Please resend the OTP',
            duration: const Duration(seconds: 2));
        EasyLoading.dismiss();
        model.isCodeSent = false;
      }
    }

    EasyLoading.show(status: 'Verifing phone number');

    await _firebaseAuth.verifyPhoneNumber(
        codeSent: onCodeSent,
        phoneNumber: "+91$phoneNumber",
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 30),
        verificationFailed: onVerificationFailed,
        verificationCompleted: onVerificationCompleted,
        codeAutoRetrievalTimeout: onTimeOut);
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
      EasyLoading.dismiss();
      LoginViewModel.instance.showOTPDialog(context);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
