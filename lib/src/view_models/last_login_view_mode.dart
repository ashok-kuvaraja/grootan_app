import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '/src/models/user_details.dart';
import '../services/firebase_auth.dart';
import '../services/firebase_store.dart';

class LastLoginViewModel extends ChangeNotifier {
  LastLoginViewModel._();

  static LastLoginViewModel instance = LastLoginViewModel._();

  List<String> pages = ['Today', 'Yesterday', 'Other'];

  Stream<QuerySnapshot> getUserDetailsAsStream() {
    return FirebaseFireStoreService.instance.getUserDetailsAsStream();
  }

  List<UserDetails> filterUserDetails(
      AsyncSnapshot<QuerySnapshot> snapshot, String day) {
    bool isValidUser(UserDetails details) {
      DateTime date = DateTime.now();
      DateTime uploadTime = DateTime.parse(details.time);
      DateTime today = DateTime(date.year, date.month, date.day);

      switch (day) {
        case 'Today':
          return uploadTime.isAfter(today);
        case 'Yesterday':
          DateTime yesterday = today.subtract(const Duration(days: 1));
          return uploadTime.isBefore(today) && uploadTime.isAfter(yesterday);
        case 'Others':
          DateTime yesterday = today.subtract(const Duration(days: 1));
          return uploadTime.isBefore(yesterday);
        default:
      }

      return false;
    }

    List<UserDetails> userDocument = <UserDetails>[];
    if (snapshot.data!.docs.isNotEmpty) {
      final QueryDocumentSnapshot? currentUser = snapshot.data?.docs
          .firstWhereOrNull((element) =>
              element.id == FirebaseAuthService.instance.currentUserID);

      if (currentUser != null && currentUser.exists) {
        userDocument = ((currentUser.data() as Map)['userDetails'] as List)
            .map((e) => UserDetails.fromMap(e))
            .where(isValidUser)
            .toList();
      }
    }
    return userDocument;
  }
}
