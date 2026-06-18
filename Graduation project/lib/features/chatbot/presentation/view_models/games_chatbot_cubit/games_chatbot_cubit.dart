import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/games_chatbot_cubit/games_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/services/games_chatbot_service.dart';

class GameChatbotCubit extends Cubit<GameChatbotState> {
  final GameChatbotService service;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => List.from(_messages);

  GameChatbotCubit(this.service) : super(GameChatbotInitial());

  void clearMessages() {
    _messages.clear();
    emit(GameChatbotInitial());
  }

  void sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add({"sender": "user", "message": userMessage});
    emit(GameChatbotUpdated(List.from(_messages)));

    try {
      emit(GameChatbotLoading(List.from(_messages)));

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
              "I couldn't find any games matching your request. Try a different title!"
        });
      }

      emit(GameChatbotUpdated(List.from(_messages)));
    } catch (e) {
      log("Error in sendMessage: $e");

      String errorMessage =
          "Oops, something went wrong. Please try again later.";

      if (e.toString().contains('Connection refused') ||
          e.toString().contains('not running') ||
          e.toString().contains('unreachable')) {
        errorMessage =
            "Cannot connect to game service. Please check your connection and try again.";
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            "Request timed out. The server might be busy, please try again.";
      }

      _messages.add({"sender": "bot", "message": errorMessage});
      emit(GameChatbotUpdated(List.from(_messages)));
    }
  }
}
