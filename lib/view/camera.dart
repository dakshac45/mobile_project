import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          getBody(),
          TextButton(
            onPressed: () {
              _getImage(ImageSource.gallery);
            },
            child: Text('Import Image'),
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: () {
              _getImage(ImageSource.camera);
            },
            child: Text('Use Camera'),
          ),
          SizedBox(height: 16.0),
          _image == null
              ? SizedBox(height: 0.0)
              : TextButton(
                  onPressed: _upload,
                  child: Text('Save'),
                ),
          SizedBox(height: 16.0),
          _image == null
              ? SizedBox(height: 0.0)
              : TextButton(
                  onPressed: _shareImage,
                  child: Text('Share'),
                ),
          SizedBox(height: 16.0),
          _image == null
              ? SizedBox(height: 0.0)
              : TextButton(
                  onPressed: _editImage,
                  child: Text('Edit Image'),
                ),
        ]
            //children: getBody(),
            ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _getImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    // Capture a photo
    final XFile? pickedImage = await _picker.pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);

        bytes = _image!.readAsBytesSync();
      } else {
        if (kDebugMode) {
          print("No image picked");
        }
      }
    });
  }

  void _upload() async {
    if (_image == null) {
      return;
    }
    var uuid = const Uuid();
    final String uuidString = uuid.v4();
    print(_image!.path);
    final String downloadUrl = await uploadFile(uuidString);
    await _addItem(downloadUrl, uuidString);
    if (kDebugMode) {
      print(uuidString);
    }
    Navigator.pop(context);
  }

  void _shareImage() async {
    if (_image == null) {
      return;
    }

    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(await _image!.readAsBytes());

    // Share file using Share plugin
    await Share.shareFiles([file.path]);
  }

  void _editImage() async {
    final currentImageBytes = await _image!.readAsBytes();
    final editedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: currentImageBytes,
        ),
      ),
    );

    Uint8List imageInUnit8List =
        editedImage as Uint8List; // store unit8List image here ;
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.png').create();
    file.writeAsBytesSync(imageInUnit8List);

    setState(() {
      _image = file;
    });
  }

  Future<String> uploadFile(String filename) async {
    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/jpeg', contentLanguage: 'en');

    // Upload the file to firebase
    UploadTask uploadTask = ref.putFile(_image!, metadata);

    // Waits till the file is uploaded then stores the download url
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    if (kDebugMode) {
      print(downloadUrl);
    }
    return downloadUrl;
  }

  Future<void> _addItem(String downloadURL, String uid) async {
    await FirebaseFirestore.instance.collection('photos').add({
      'downloadURL': downloadURL,
      'imageId': uid,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Widget getBody() {
    return Container(
        margin: const EdgeInsets.all(10.0),
        width: 200,
        height: 200,
        color: Colors.white,
        child: _image == null
            ? Image.network(
                "https://cdn.dribbble.com/users/55871/screenshots/2158022/media/95f08ed3812af28b93fa534fb5d277b3.jpg")
            : Image.file(_image!));
  }
}
