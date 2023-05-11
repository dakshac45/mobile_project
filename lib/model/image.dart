import 'package:cloud_firestore/cloud_firestore.dart';

class Image {
  String uid;
  String id;
  String imageUrl;

  Image({
    required this.uid,
    required this.id,
     required this.imageUrl
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "id": id,
        "imageUrl": imageUrl
      };

  static Image fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Image(
        uid: snapshot['uid'],
        id: snapshot['id'],
        imageUrl: snapshot['imageUrl']);
  }
}

