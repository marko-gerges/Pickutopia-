import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/series_chatbot_cubit/series_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/services/series_chatbot_service.dart';

class TvShowsChatbotCubit extends Cubit<TvShowsChatbotState> {
  final SeriesChatbotService service;
  final List<Map<String, String>> _messages = [];

  List<Map<String, String>> get messages => List.from(_messages);

  TvShowsChatbotCubit(this.service) : super(TvShowsChatbotInitial());

  void clearMessages() {
    _messages.clear();
    emit(TvShowsChatbotInitial());
  }

  void sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _messages.add({"sender": "user", "message": userMessage});
    emit(TvShowsChatbotLoading(messages: List.from(_messages)));

    try {
      final response = await service.sendMessage(userMessage);

      final botMessage = response["message"] as String?;
      final recommendations = response["recommendations"] as List<String>?;

      if (botMessage != null && botMessage.isNotEmpty) {
        _messages.add({"sender": "bot", "message": botMessage});
      }

      if (recommendations != null && recommendations.isNotEmpty) {
        for (final title in recommendations) {
          _messages.add({"sender": "bot", "message": title});
        }
      } else if (botMessage == null || botMessage.isEmpty) {
        _messages.add({
          "sender": "bot",
          "message":
              "I couldn't find any series matching your request. Try a different title!"
        });
      }

      emit(TvShowsChatbotUpdated(
        messages: List.from(_messages),
        recommendations: recommendations ?? [],
      ));
    } catch (e) {
      log("Error in sendMessage: $e");

      String errorMessage =
          "Oops, something went wrong. Please try again later.";

      if (e.toString().contains('Connection refused') ||
          e.toString().contains('not running') ||
          e.toString().contains('unreachable')) {
        errorMessage =
            "Cannot connect to the TV show service. Please check your connection.";
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            "Request timed out. The server might be busy, please try again.";
      }

      _messages.add({"sender": "bot", "message": errorMessage});
      emit(TvShowsChatbotError(
        errorMessage: errorMessage,
        messages: List.from(_messages),
      ));
    }
  }
}
