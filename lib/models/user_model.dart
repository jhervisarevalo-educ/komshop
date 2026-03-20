class UserModel {
  String? uid;
  String name;
  String email;
  String userType;
  String? contactNo;
  String? address;   

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.userType,
    this.contactNo,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userType: map['userType'] ?? 'user',
      contactNo: map['contactNo'], 
      address: map['address'],    
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'userType': userType,
      'contactNo': contactNo,
      'address': address,    
    };
  }
}