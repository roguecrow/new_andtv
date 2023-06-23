class User {
  final int clinicId;
  final int doctorId;
  final String doctorName;

  User({
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'clinicId': clinicId,
      'doctorId': doctorId,
      'doctorName': doctorName,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      clinicId: json['clinicId'] as int,
      doctorId: json['doctorId'] as int,
      doctorName: json['doctorName'] as String,
    );
  }
}
