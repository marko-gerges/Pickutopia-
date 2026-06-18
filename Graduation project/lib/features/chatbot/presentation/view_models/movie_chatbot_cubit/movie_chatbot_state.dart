abstract class MovieChatbotState {}

class MovieChatbotInitial extends MovieChatbotState {}

class MovieChatbotLoading extends MovieChatbotState {
  final List<Map<String, String>> messages;

  MovieChatbotLoading([this.messages = const []]);
}

class MovieChatbotUpdated extends MovieChatbotState {
  final List<Map<String, String>> messages;

  MovieChatbotUpdated(this.messages);
}

class MovieChatbotError extends MovieChatbotState {
  final String errorMessage;
  final List<Map<String, String>> messages;

  MovieChatbotError(this.errorMessage, [this.messages = const []]);
}
