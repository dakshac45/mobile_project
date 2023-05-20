import 'package:flutter/material.dart';
import 'package:flutter_project/controller/auth.dart';
import 'package:flutter_project/view/camera.dart';
import 'package:flutter_project/view/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key) {
    _stream = _reference.snapshots();
  }

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('photos');

  late Stream<QuerySnapshot> _stream;
  void _signout() async {
    AuthHelper().signOut();
    Get.offAll(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: _signout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Check error
          if (snapshot.hasError) {
            return Center(child: Text('Some error occurred ${snapshot.error}'));
          }

          //Check if data arrived
          if (snapshot.hasData) {
            //get the data
            QuerySnapshot querySnapshot = snapshot.data;
            List<QueryDocumentSnapshot> documents = querySnapshot.docs;

            //Convert the documents to Maps
            List<Map> items = documents.map((e) => e.data() as Map).toList();
            List<String> currentUserPhotos = [];
            for (var element in items) {
              if (element['userId'] == AuthHelper().getUser()!.uid) {
                currentUserPhotos.add(element['downloadURL']);
              }
            }

            if (currentUserPhotos.isEmpty) {
              return Center(
                  child: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: const Text("You have no images")));
            }

            //Display the list
            return ListView.builder(
                itemCount: currentUserPhotos.length,
                itemBuilder: (BuildContext context, int index) {
                  //Get the item at this index
                  // print(index);
                  String thisItem = currentUserPhotos[index];
                  //REturn the widget for the list items
                  return Padding(
                    padding: EdgeInsets.all(20),
                    child: Card(
                      shape: Border.all(
                        width: 5,
                      ),
                      elevation: 20,
                      color: Colors.black,
                      child: Column(
                        children: <Widget>[
                          Image.network(thisItem),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }

          //Show loader
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {Get.to(CameraPage())},
        tooltip: 'Choose Photo',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
