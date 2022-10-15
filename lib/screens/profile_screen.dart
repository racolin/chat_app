import 'dart:io';

import 'package:chat_app/models/my_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  static const String route = '/profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? avatar;
  MyUser? myUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.doc('users/$uid').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Container();
          }
          var data = snapshot.data as DocumentSnapshot<Map<String, dynamic>>;
          myUser = MyUser.fromMapDetail(data.id, data.data()!);
          _textController.text = myUser!.username;
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(108),
                    child: SizedBox(
                      height: 216,
                      width: 216,
                      child: GridTile(
                        footer: InkResponse(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(216),
                            bottomRight: Radius.circular(216),
                          ),
                          radius: 108,
                          onTap: () async {
                            var xImage = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              maxHeight: 432,
                              maxWidth: 432,
                            );
                            if (xImage != null) {
                              setState(() {
                                avatar = xImage.path;
                              });
                            }
                          },
                          child: Container(
                            height: 48,
                            color: Colors.black.withOpacity(0.8),
                            child: const Center(
                              child: Icon(
                                Icons.camera,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        child: avatar != null
                            ? Image.file(File(avatar!))
                            : FutureBuilder(
                                future: FirebaseStorage.instance
                                    .ref('users/avatars/$uid.jpg')
                                    .getDownloadURL()
                                    .catchError(
                                      (error, stackTrace) => FirebaseStorage
                                          .instance
                                          .ref(
                                              'users/avatars/default_avatar.jpg')
                                          .getDownloadURL(),
                                    ),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  return Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                    height: 128,
                                    width: 128,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.black.withAlpha(164),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      print('object$avatar');
                      if (avatar != null) {
                        FirebaseStorage.instance
                            .ref()
                            .child('users/avatars/$uid.jpg')
                            .putFile(
                              File(avatar!),
                              SettableMetadata(contentType: 'image/jpeg'),
                            );
                      }
                      if (_textController.text.isNotEmpty &&
                          _textController.text != myUser!.username) {
                        FirebaseFirestore.instance
                            .doc('users/$uid')
                            .update({'username': _textController.text});
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: const Text('Save'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
