import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String email;

  User({
    required this.uid,
    required this.email
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email ": email
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    print(snapshot);
    return User(
        uid: snapshot['uid'].toString(),
        email: snapshot['email'].toString());
  }
}