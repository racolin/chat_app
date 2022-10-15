import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUser {
  late String uid;
  late String avatarUrl;
  late String username;
  late List<String> chatIds;
  late String email;

  MyUser({
    required this.uid,
    required this.avatarUrl,
    required this.username,
    this.chatIds = const [],
    this.email = '',
  });

  // Map<String, dynamic> t

  MyUser.fromQueryDocument(QueryDocumentSnapshot<Object?> queryDocument) {
    uid = queryDocument.id;
    avatarUrl = queryDocument['avatarUrl'];
    username = queryDocument['username'];
    chatIds = (queryDocument['chatIds'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    email = queryDocument['email'];
  }

  MyUser.fromMapShort(Map<String, dynamic> map) {
    uid = map['uid'];
    avatarUrl = map['avatarUrl'];
    username = map['username'];
    email = map['email'];
    chatIds = [];
  }

  MyUser.fromMapDetail(String id, Map<String, dynamic> map) {
    uid = id;
    avatarUrl = map['avatarUrl'];
    username = map['username'];
    email = map['email'];
    chatIds = (map['chatIds'] as List<dynamic>)
        .map((e) => (e as String).trim())
        .toList();
  }

  Map<String, dynamic> toMapDetail() {
    return {
      'avatarUrl': avatarUrl,
      'username': username,
      'email': email,
      'chatIds': chatIds,
    };
  }

  Map<String, dynamic> toMapShort() {
    return {
      'uid': uid,
      'avatarUrl': avatarUrl,
      'username': username,
      'email': email,
    };
  }
}
