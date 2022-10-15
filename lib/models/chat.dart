import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/my_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  late String id;
  late String chatAvatarUrl;
  late String chatName;
  late Message lastMessage;
  late List<MyUser> users;

  Chat({
    required this.id,
    required this.chatName,
    required this.chatAvatarUrl,
    required this.lastMessage,
    required this.users,
  });

  Chat.fromMap(this.id, Map<String, dynamic> map) {
    chatName = map['chatName'];
    chatAvatarUrl = map['chatAvatarUrl'];
    lastMessage = Message.fromMap(
      '',
      map['lastMessage'] as Map<String, dynamic>,
    );
    users = (map['users'] as List<dynamic>)
        .map(
          (e) => MyUser.fromMapShort(e as Map<String, dynamic>),
        )
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'chatName': chatName,
      'chatAvatarUrl': chatAvatarUrl,
      'lastMessage': lastMessage.toMap(),
      'users': users.map((e) => e.toMapShort()).toList(),
    };
  }

  void addChatToFirebase() {
    FirebaseFirestore.instance.collection('chats').doc(id).set(toMap());
  }
}
