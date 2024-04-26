import 'package:chat_app/widgets/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('created', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData) {
            return const Center(child: Text('No messages found.'));
          }
          final loadedMessages = chatSnapshot.data!.docs;
          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, idx) {
                final chatMessage = loadedMessages[idx].data();
                final nextChatMessage = idx + 1 < loadedMessages.length
                    ? loadedMessages[idx + 1].data()
                    : null;
                final currentMessageUserId = chatMessage['userId'];
                final nextMessageUserId = nextChatMessage != null
                    ? nextChatMessage['userId']
                    : null;
                final nextUserIsSame = nextMessageUserId == currentMessageUserId;
                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                } else {
                  return MessageBubble.first(userImage: chatMessage['userImage'],
                      username: chatMessage['username'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentMessageUserId);
                }
                return Text(loadedMessages[idx]['text']);
              });
        });
  }
}
