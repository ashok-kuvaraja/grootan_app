/// A Class [UserDetails] that holds an user login details.
class UserDetails {
  UserDetails(
      {required this.qrCodeURL,
      required this.randomNumber,
      required this.city,
      required this.userIP,
      required this.time});

  final String qrCodeURL;
  final int randomNumber;
  final String city;
  final String userIP;
  final String time;

  Map<String, dynamic> toMap() {
    return {
      'qrCodeURL': qrCodeURL,
      'randomNumber': randomNumber,
      'city': city,
      'userIP': userIP,
      'time': time,
    };
  }

  factory UserDetails.fromMap(Map<String, dynamic> map) {
    return UserDetails(
      qrCodeURL: map['qrCodeURL'] ?? '',
      randomNumber: map['randomNumber']?.toInt() ?? 0,
      city: map['city'] ?? '',
      userIP: map['userIP'] ?? '',
      time: map['time'] ?? '',
    );
  }
}
