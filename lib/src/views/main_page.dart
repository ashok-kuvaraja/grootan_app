import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/firebase_auth.dart';
import 'plugin_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSignedIn = FirebaseAuthService.instance.currentUserID.isEmpty;
    return MaterialApp(
      title: 'Grootan App',
      home: isSignedIn ? const LoginPage() : const PluginPage(),
      builder: EasyLoading.init(),
    );
  }
}
