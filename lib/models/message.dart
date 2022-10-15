import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late String id;
  late String content;
  late Timestamp createAt;
  late String createBy;

  Message(
    this.id,
    this.content,
    this.createAt,
    this.createBy,
  );

  Message.fromMap(this.id, Map<String, dynamic> map) {
    content = map['content'];
    createAt = map['createAt'];
    createBy = map['createBy'];
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createAt': createAt,
      'createBy': createBy,
    };
  }
}
