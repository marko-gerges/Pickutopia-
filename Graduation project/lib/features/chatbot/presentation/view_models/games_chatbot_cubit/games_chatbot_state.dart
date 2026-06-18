abstract class GameChatbotState {}

class GameChatbotInitial extends GameChatbotState {}

class GameChatbotLoading extends GameChatbotState {
  final List<Map<String, String>> messages;

  GameChatbotLoading([this.messages = const []]);
}

class GameChatbotUpdated extends GameChatbotState {
  final List<Map<String, String>> messages;

  GameChatbotUpdated(this.messages);
}

class GameChatbotError extends GameChatbotState {
  final String errorMessage;
  final List<Map<String, String>> messages;

  GameChatbotError(this.errorMessage, [this.messages = const []]);
}
