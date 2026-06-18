import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/music_chatbot_cubit/music_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/services/music_chatbot_service.dart';

class MusicChatbotCubit extends Cubit<MusicChatbotState> {
  final MusicChatbotService service;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => List.from(_messages);

  MusicChatbotCubit(this.service) : super(MusicChatbotInitial());

  void clearMessages() {
    _messages.clear();
    emit(MusicChatbotInitial());
  }

  void sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add({"sender": "user", "message": userMessage});
    emit(MusicChatbotUpdated(List.from(_messages)));

    try {
      emit(MusicChatbotLoading(List.from(_messages)));

      final response = await service.sendQuery(userMessage);

      final botMessage = response["message"] as String?;
      if (botMessage != null && botMessage.isNotEmpty) {
        _messages.add({"sender": "bot", "message": botMessage});
      }

      final recommendations = response["recommendations"] as List?;
      if (recommendations != null && recommendations.isNotEmpty) {
        if ((botMessage == null || botMessage.isEmpty) &&
            recommendations.isNotEmpty) {
          _messages.add({
            "sender": "bot",
            "message": "Here are some songs you might enjoy:"
          });
        }

        for (final rec in recommendations) {
          final name = rec['name'] as String?;
          final artist = rec['artist'] as String?;

          if (name != null && artist != null) {
            _messages.add({"sender": "bot", "message": "$name by $artist"});
          }
        }
      } else if (botMessage == null || botMessage.isEmpty) {
        _messages.add({
          "sender": "bot",
          "message":
              "I couldn't find any songs matching your request. Try something else!"
        });
      }

      emit(MusicChatbotUpdated(List.from(_messages)));
    } catch (e) {
      log("Error in sendMessage: $e");

      String errorMessage =
          "Oops, something went wrong. Please try again later.";

      if (e.toString().contains('Connection refused') ||
          e.toString().contains('not running') ||
          e.toString().contains('unreachable')) {
        errorMessage =
            "Cannot connect to music service. Please check your connection and try again.";
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            "Request timed out. The server might be busy, please try again.";
      }

      _messages.add({"sender": "bot", "message": errorMessage});
      emit(MusicChatbotUpdated(List.from(_messages)));
    }
  }
}
