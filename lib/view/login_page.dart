import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../const.dart';
import '../widgets/common.dart';
import '../view_model/login_view_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GrootanAppPage(
      pageTitle: 'LOGIN',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Consumer<LoginViewModel>(builder:
              (BuildContext context, LoginViewModel model, Widget? child) {
            return Form(
              key: model.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SpaceProvider(height: 100.0),
                  const Text('Phone Numer',
                      style:
                          TextStyle(color: defaultTextColor, fontSize: 20.0)),
                  const SpaceProvider(),
                  _buildPhoneNumberField(model),
                  const SpaceProvider(),
                  const Text('OTP',
                      style:
                          TextStyle(color: defaultTextColor, fontSize: 20.0)),
                  const SpaceProvider(),
                  _buildOTPField(model),
                  const SpaceProvider(height: 60.0),
                  _buildSubmitButton(model, context),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(LoginViewModel model) {
    String? onValidateForm(String? value) {
      if (!model.isCodeSent &&
          (value == null || value.isEmpty || value.length < 10)) {
        return 'Please enter valid number';
      }
    }

    return SizedBox(
      height: 70.0,
      child: TextFormField(
        maxLength: 10,
        enabled: !model.isCodeSent,
        validator: onValidateForm,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
        controller: model.phoneNumberController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          prefix: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text('+91', style: TextStyle(color: Colors.white))),
          filled: true,
          fillColor: primaryColor,
          border: OutlineInputBorder(borderRadius: defaultBorderRadius),
        ),
      ),
    );
  }

  Widget _buildOTPField(LoginViewModel model) {
    String? onValidateForm(String? value) {
      if (model.isCodeSent &&
          (value == null || value.isEmpty || value.length < 6)) {
        return 'Please enter a valid OTP';
      }
    }

    return SizedBox(
      height: 70.0,
      child: TextFormField(
        maxLength: 6,
        validator: onValidateForm,
        enabled: model.isCodeSent,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
        style: const TextStyle(color: Colors.white),
        controller: model.otpController,
        decoration: const InputDecoration(
          filled: true,
          fillColor: primaryColor,
          border: OutlineInputBorder(borderRadius: defaultBorderRadius),
        ),
      ),
    );
  }

  RoundedButton _buildSubmitButton(LoginViewModel model, BuildContext context) {
    const TextStyle style = TextStyle(
        color: defaultTextColor, fontWeight: FontWeight.bold, fontSize: 20.0);

    return RoundedButton(
      child: Visibility(
          visible: !model.isCodeSent,
          replacement: const Text('LOGIN', style: style),
          child: const Text('Send OTP', style: style)),
      onPressed: () async {
        await model.onSubmit(context);
      },
    );
  }
}
