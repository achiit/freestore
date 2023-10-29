class UserData {
  final String fullname;
  final String profileImage;
  final String email;
  final Map<String, dynamic> myposts;

  UserData({
    required this.fullname,
    required this.profileImage,
    required this.email,
    required this.myposts,
  });

  factory UserData.fromMap(Map<dynamic, dynamic> map) {
    return UserData(
      fullname: map['fullname'],
      profileImage: map['profileImage'],
      email: map['email'],
      myposts: Map<String, dynamic>.from(map['myposts']),
    );
  }
}
