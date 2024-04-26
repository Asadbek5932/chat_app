import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessagesState();
  }
}

class _NewMessagesState extends State<NewMessage> {
  var _messageController = TextEditingController();


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage == null || enteredMessage
        .trim()
        .isEmpty || enteredMessage
        .trim()
        .length < 4) {
      return;
    }
    _messageController.clear();
    FocusScope.of(context).unfocus();

    final _currentUser = FirebaseAuth.instance.currentUser!;
    final _userData = await FirebaseFirestore.instance.collection('users').doc(
        _currentUser.uid).get();


    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'created': Timestamp.now(),
      'userId': _currentUser.uid,
      'username': _userData.data()!['user_name'],
      'userImage': _userData.data()!['imageUrl']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                decoration: const InputDecoration(
                    labelText: 'Send a message...'),
                controller: _messageController,
              )),
          IconButton(onPressed: _submitMessage, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
