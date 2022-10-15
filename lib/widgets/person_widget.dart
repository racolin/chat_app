import 'package:chat_app/models/my_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PersonWidget extends StatelessWidget {
  final MyUser user;
  final Function addToFriends;
  const PersonWidget({
    Key? key,
    required this.user,
    required this.addToFriends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        // contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(48),
          child: FutureBuilder(
            future: FirebaseStorage.instance
                .ref('users/avatars/${user.uid}')
                .getDownloadURL()
                .catchError((error, stackTrace) => FirebaseStorage.instance
                    .ref('users/avatars/default_avatar.jpg')
                    .getDownloadURL()),
            builder: (context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return Image.network(
                snapshot.data!,
                // height: 48,
                // width: 48,
              );
            },
          ),
        ),
        title: Text(user.username),
        subtitle: const Text('Add to friends'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(
            Icons.person_add,
            color: Colors.blue,
          ),
          onPressed: () {
            addToFriends(user);
          },
        ),
      ),
    );
  }
}
