import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/widgets/message_widget.dart';
import 'package:chat_app/models/my_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const route = '/chat_screen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Chat chat;

  final TextEditingController _textController = TextEditingController();
  // final _scrollController = ScrollController();
  final FocusNode _textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    chat = ModalRoute.of(context)!.settings.arguments as Chat;
    super.didChangeDependencies();
  }

  String _getChatName(String uid) {
    return chat.users.firstWhere((element) => element.uid != uid).username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getChatName(uid)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chat.id)
                    .collection('messages')
                    .orderBy('createAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  List<Message> messages =
                      (snapshot.data as QuerySnapshot<Map<String, dynamic>>)
                          .docs
                          .map(
                    (e) {
                      return Message.fromMap(e.id, e.data());
                    },
                  ).toList();
                  return ListView.builder(
                    // controller: _scrollController,
                    itemBuilder: (context, index) {
                      return MessageWidget(
                        key: ValueKey(
                          messages[index].id,
                        ),
                        message: messages[index],
                      );
                    },
                    itemCount: messages.length,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.link,
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFocus,
                    maxLines: null,
                    maxLength: 250,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          top: 8, left: 16, bottom: 8, right: 8),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.7),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      var timeStamp = Timestamp.now();
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chat.id)
                          .update({
                        'lastMessage': {
                          'content': _textController.text,
                          'createAt': timeStamp,
                          'createBy': uid,
                        },
                      });
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chat.id)
                          .collection('messages')
                          .add({
                        'content': _textController.text,
                        'createAt': timeStamp,
                        'createBy': uid,
                      }).then((data) {
                        setState(() {
                          _textController.text = '';
                          // _scrollController.animateTo(
                          //   _scrollController.position.maxScrollExtent + 1000,
                          //   duration: const Duration(microseconds: 600),
                          //   curve: Curves.easeIn,
                          // );
                        });
                      });
                    } else {}
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
