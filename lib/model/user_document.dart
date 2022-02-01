import '../model/user_details.dart';

/// A Class [UserDocument] that holds a collection of [UserDetails].
class UserDocument {
  UserDocument({required this.userDetails});
  final List<UserDetails> userDetails;

  Map<String, dynamic> toMap() {
    return {
      'userDetails': userDetails.map((x) => x.toMap()).toList(),
    };
  }

  factory UserDocument.fromMap(Map<String, dynamic> map) {
    return UserDocument(
      userDetails: List<UserDetails>.from(
          map['userDetails']?.map((x) => UserDetails.fromMap(x))),
    );
  }
}
