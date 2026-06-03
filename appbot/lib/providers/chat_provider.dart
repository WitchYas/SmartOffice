import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ChatProvider with ChangeNotifier {
  final List<ChatModel> _chatMessages = [];

  List<ChatModel> get getChatMessages => _chatMessages;

  void addUserMsg({required String message}) {
    _chatMessages.add(ChatModel(message: message, chatMessageType: ChatMessageType.user));
    notifyListeners();
  }

  Future<void> addBotMessage({required String message}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final msg = message.toLowerCase();
    String botResponse = await _getBotResponse(msg);

    _chatMessages.add(ChatModel(message: botResponse, chatMessageType: ChatMessageType.bot));
    notifyListeners();
  }

  Future<String> _getBotResponse(String msg) async {
    if (msg.contains('temperature')) {
      return await _readFirestoreValue('temp', '°C');
    } else if (msg.contains('motion')) {
      return await _readFirestoreValue('motion', '%');
    } else if (msg.contains('energy')) {
      return await _readFirestoreValue('energy', 'kWh');
    } else if (msg.contains('hello') || msg.contains('hi')) {
      return 'Hi there! How can I assist you today?';
    } else if (msg.contains('light')) {
      if (msg.contains('on')) {
        return 'Sure, turning on the lights.';
      } else if (msg.contains('off')) {
        return 'Okay, turning off the lights.';
      } else {
        return 'Would you like the lights on or off?';
      }
    } else if (msg.contains('door') || msg.contains('lock')) {
      return 'Security system engaged. Do you want to lock or unlock the door?';
    } else if (msg.contains('thanks') || msg.contains('thank you')) {
      return 'welcome! 😊';
    } else if (msg.contains('who are you')) {
      return 'Your smart assistant chatbot. I help you manage your smart office!';
    } else {
      return 'Sorry, I didnt understand that. Can you rephrase or try another command?';
    }
  }

  Future<String> _readFirestoreValue(String docId, String unit) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('status')
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        final value = doc.data()!['value'];
        return 'The current $docId is $value $unit.';
      } else {
        return 'Sorry, no data found for $docId.';
      }
    } catch (e) {
      return 'Error reading $docId from Firebase.';
    }
  }
}
