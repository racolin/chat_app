import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/my_user.dart';
import '../models/chat.dart';
import '../widgets/chat_widget.dart';

class ChatListWidget extends StatelessWidget {
  const ChatListWidget({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        // Neu chua co data thi loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
          // Neu da co data thi lay data
        } else if (snapshot.hasData) {
          var data = snapshot.data!.data();
          // Neu data rong thi khong co gi de show
          if (data == null || snapshot.data!.data() == null) {
            return Container();
            // Neu data khac rong thi lay data ra va dua vao user
          } else {
            MyUser myUser = MyUser.fromMapDetail(
              snapshot.data!.id,
              snapshot.data!.data()!,
            );
            if (myUser.chatIds.isEmpty) {
              return Container();
            }
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where(FieldPath.documentId, whereIn: myUser.chatIds)
                  .snapshots(),
              builder: (context, snapshot) {
                // Neu khong co data thi tra ve container rong
                if (!snapshot.hasData) {
                  return Container();
                }
                // Neu co data thi tra ve mot list
                var list =
                    (snapshot.data as QuerySnapshot<Map<String, dynamic>>).docs;
                List<Chat> chats = list.map((e) {
                  return Chat.fromMap(e.id, e.data());
                }).toList();
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      key: ValueKey(chats[index].users.join('-')),
                      chat: chats[index],
                    );
                  },
                  itemCount: chats.length,
                );
              },
            );
          }
        } else {
          return const Center(
            child: Text('Don\'t have any user.'),
          );
        }
      },
    );
  }
}
