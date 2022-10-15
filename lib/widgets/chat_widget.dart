import 'package:chat_app/models/chat.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatWidget extends StatelessWidget {
  final Chat chat;
  const ChatWidget({Key? key, required this.chat}) : super(key: key);
  String _getChatName(String uid) {
    return chat.users.firstWhere((element) => element.uid != uid).username;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lastUser = chat.users.firstWhere(
      (element) => element.uid == chat.lastMessage.createBy,
    );
    final otherUser = chat.users.firstWhere(
      (element) => element.uid != uid,
    );
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          ChatScreen.route,
          arguments: chat,
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: FutureBuilder(
                future: FirebaseStorage.instance
                    .ref()
                    .child('users/avatars/${otherUser.uid}.jpg')
                    .getDownloadURL()
                    .catchError((error, stackTrace) => FirebaseStorage.instance
                        .ref()
                        .child('users/avatars/default_avatar.jpg')
                        .getDownloadURL()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return Image.network(snapshot.data as String);
                },
              ),
            ),
            title: Text(_getChatName(uid)),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    '${uid == lastUser.uid ? 'You' : lastUser.username.split(' ').last} : ${chat.lastMessage.content}',
                    maxLines: 1,
                  ),
                ),
                Text(
                  DateFormat('HH:mm EEE').format(
                    chat.lastMessage.createAt.toDate(),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }
}
