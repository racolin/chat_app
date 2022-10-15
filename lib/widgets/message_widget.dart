import 'package:chat_app/models/message.dart';
import 'package:chat_app/widgets/triagle_clipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  const MessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    bool isMe = message.createBy == uid;
    return Container(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.minPositive,
      child: Stack(
        children: [
          Positioned(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: isMe
                      ? BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          color: Colors.purple.withOpacity(0.7),
                        )
                      : BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(24),
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          color: Colors.blue.withOpacity(0.7),
                        ),
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Text(
                    message.content,
                    style: const TextStyle(
                      letterSpacing: 1,
                      wordSpacing: 2,
                      height: 1.25,
                    ),
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    margin: isMe
                        ? const EdgeInsets.only(right: 24, bottom: 8)
                        : const EdgeInsets.only(left: 24, bottom: 8),
                    height: 18,
                    width: 18,
                    color: isMe
                        ? Colors.purple.withOpacity(0.7)
                        : Colors.blue.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          isMe
              ? Positioned(
                  bottom: 0,
                  right: 24,
                  child: Text(
                    DateFormat('HH:mm EEE').format(message.createAt.toDate()),
                  ),
                )
              : Positioned(
                  bottom: 0,
                  left: 24,
                  child: Text(
                    DateFormat('HH:mm EEE').format(message.createAt.toDate()),
                  ),
                ),
        ],
      ),
    );
  }
}
