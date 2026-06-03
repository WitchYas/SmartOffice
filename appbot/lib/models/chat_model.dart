enum ChatMessageType { user, bot }

class ChatModel {
  final String message;
  final ChatMessageType chatMessageType;

  ChatModel({required this.message, required this.chatMessageType});
}
