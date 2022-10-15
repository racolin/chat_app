import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/my_user.dart';
import 'package:chat_app/widgets/person_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PeopleWidget extends StatefulWidget {
  const PeopleWidget({Key? key}) : super(key: key);

  @override
  State<PeopleWidget> createState() => _PeopleWidgetState();
}

class _PeopleWidgetState extends State<PeopleWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var data = snapshot.data as QuerySnapshot<Map<String, dynamic>>;
        List<MyUser> listUser =
            data.docs.map((e) => MyUser.fromMapDetail(e.id, e.data())).toList();

        var i = listUser.indexWhere(
            (element) => element.uid == FirebaseAuth.instance.currentUser!.uid);

        var myUser = listUser.removeAt(i);

        for (var chatId in myUser.chatIds) {
          listUser.removeWhere((u) => u.chatIds.contains(chatId));
        }

        void addToFriends(MyUser u) {
          var content = 'Hello! I\'m ${myUser.username}.';
          var chats = FirebaseFirestore.instance.collection('chats');
          var chatId = chats.doc().id;
          var messageId = chats.doc(chatId).collection('messages').doc().id;
          var message = Message(
            messageId,
            content,
            Timestamp.now(),
            myUser.uid,
          );

          chats
              .doc(chatId)
              .collection('messages')
              .doc(messageId)
              .set(message.toMap());

          Chat(
            id: chatId,
            chatName: 'chatName',
            chatAvatarUrl: 'chatAvatarUrl',
            lastMessage: Message(
              messageId,
              content,
              Timestamp.now(),
              myUser.uid,
            ),
            users: [u, myUser],
          ).addChatToFirebase();

          myUser.chatIds.add(chatId);
          FirebaseFirestore.instance
              .doc('users/${myUser.uid}')
              .update({'chatIds': myUser.chatIds});

          u.chatIds.add(chatId);
          FirebaseFirestore.instance
              .doc('users/${u.uid}')
              .update({'chatIds': u.chatIds});
        }

        return ListView.builder(
          itemCount: listUser.length,
          itemBuilder: (context, index) {
            return PersonWidget(
              user: listUser[index],
              addToFriends: addToFriends,
            );
          },
        );
      },
    );
  }
}
