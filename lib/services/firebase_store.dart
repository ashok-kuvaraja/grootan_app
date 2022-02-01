import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../model/user_details.dart';
import '../model/user_document.dart';
import '../services/firebase_auth.dart';

class FirebaseFireStoreService {
  FirebaseFireStoreService._();

  static FirebaseFireStoreService instance = FirebaseFireStoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collectionName = 'login_details';

  String get _currentUserID => FirebaseAuthService.instance.currentUserID;

  Future<void> createUser(UserDetails details) async {
    final DocumentReference<Map> reference =
        _firestore.collection(_collectionName).doc(_currentUserID);
    final DocumentSnapshot<Map> snapshot = await reference.get();

    if (snapshot.exists) {
      List<dynamic>? currentUserDetails = _convertSnapshotToList(snapshot);
      if (currentUserDetails != null && currentUserDetails.isNotEmpty) {
        final List<UserDetails> oldUserDetails =
            currentUserDetails.map((e) => UserDetails.fromMap(e)).toList();
        oldUserDetails.add(details);

        final UserDocument document = UserDocument(userDetails: oldUserDetails);
        await reference.update(document.toMap());
      }
    } else {
      final UserDocument document = UserDocument(userDetails: [details]);
      await reference.set(document.toMap());
    }
  }

  Future<void> updateUser(String qrDownloadLink, int randomNumber) async {
    final DocumentReference<Map> reference =
        _firestore.collection(_collectionName).doc(_currentUserID);
    final DocumentSnapshot<Map> snapshot = await reference.get();

    if (snapshot.exists) {
      List<dynamic>? currentUserDetails = _convertSnapshotToList(snapshot);
      if (currentUserDetails != null && currentUserDetails.isNotEmpty) {
        if (currentUserDetails.last?['qrCodeURL']?.isNotEmpty &&
            currentUserDetails.last?['randomNumber'] != -1) {
          if (currentUserDetails.last?['qrCodeURL'] == qrDownloadLink &&
              currentUserDetails.last?['randomNumber'] == randomNumber) {
            EasyLoading.showInfo('Data already updated');
            EasyLoading.dismiss();
            return;
          }
        }

        final UserDetails newDetails = UserDetails(
            userIP: currentUserDetails.last?['userIP'] ?? '',
            city: currentUserDetails.last?['city'] ?? '',
            time: currentUserDetails.last?['time'] ?? '',
            qrCodeURL: qrDownloadLink,
            randomNumber: randomNumber);
        final List<UserDetails> userDocument =
            currentUserDetails.map((e) => UserDetails.fromMap(e)).toList();
        userDocument.removeLast();
        userDocument.add(newDetails);

        final UserDocument document = UserDocument(userDetails: userDocument);
        await reference.update(document.toMap());
        EasyLoading.showSuccess('Data has been saved successfully');
        EasyLoading.dismiss();
      }
    }
  }

  Future<String> getLastCheckInTime() async {
    final DocumentReference<Map> reference =
        _firestore.collection(_collectionName).doc(_currentUserID);
    final DocumentSnapshot<Map> snapshot = await reference.get();

    if (snapshot.exists) {
      List? currentUserDetails = _convertSnapshotToList(snapshot);
      if (currentUserDetails != null && currentUserDetails.isNotEmpty) {
        final String? time = currentUserDetails.last?['time'];
        if (time != null && time.isNotEmpty) {
          return DateFormat("h a").format(DateTime.parse(time));
        }
      }
    }
    return '';
  }

  Stream<QuerySnapshot> getUserDetailsAsStream() {
    return _firestore.collection(_collectionName).snapshots();
  }

  List? _convertSnapshotToList(DocumentSnapshot<Map> snapshot) {
    final Map? data = snapshot.data();
    if (data != null && data.isNotEmpty) {
      final List<dynamic>? currentUserDetails =
          snapshot.data()?['userDetails'] as List<dynamic>?;
      if (currentUserDetails != null && currentUserDetails.isNotEmpty) {
        return currentUserDetails;
      }
    }
  }
}
