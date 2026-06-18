import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickutopia/features/chatbot/services/anime_chatbot_service.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/anime_chatbot_cubit/anime_chatbot_state.dart';

class AnimeChatbotCubit extends Cubit<AnimeChatbotState> {
  final AnimeChatbotService service;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => List.from(_messages);

  AnimeChatbotCubit(this.service) : super(AnimeChatbotInitial());

  void clearMessages() {
    _messages.clear();
    emit(AnimeChatbotInitial());
  }

  void sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add({"sender": "user", "message": userMessage});
    emit(AnimeChatbotUpdated(List.from(_messages)));

    try {
      emit(AnimeChatbotLoading(List.from(_messages)));

      final response = await service.sendMessage(userMessage);

      final botMessage = response["message"] as String?;
      if (botMessage != null && botMessage.isNotEmpty) {
        _messages.add({"sender": "bot", "message": botMessage});
      }

      final recommendations = response["recommendations"] as List<String>?;
      if (recommendations != null && recommendations.isNotEmpty) {
        for (final title in recommendations) {
          _messages.add({"sender": "bot", "message": title});
        }
      } else if (botMessage == null || botMessage.isEmpty) {
        _messages.add({
          "sender": "bot",
          "message":
              "I couldn't find any anime matching your request. Try a different title!"
        });
      }

      emit(AnimeChatbotUpdated(List.from(_messages)));
    } catch (e) {
      log("Error in sendMessage: $e");

      String errorMessage =
          "Oops, something went wrong. Please try again later.";

      if (e.toString().contains('Connection refused') ||
          e.toString().contains('not running') ||
          e.toString().contains('unreachable')) {
        errorMessage =
            "Cannot connect to anime service. Please check your connection and try again.";
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            "Request timed out. The server might be busy, please try again.";
      }

      _messages.add({"sender": "bot", "message": errorMessage});
      emit(AnimeChatbotUpdated(List.from(_messages)));
    }
  }
}
