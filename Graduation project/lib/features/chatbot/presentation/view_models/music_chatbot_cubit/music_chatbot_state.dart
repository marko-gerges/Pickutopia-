abstract class MusicChatbotState {}

class MusicChatbotInitial extends MusicChatbotState {}

class MusicChatbotLoading extends MusicChatbotState {
  final List<Map<String, String>> messages;

  MusicChatbotLoading([this.messages = const []]);
}

class MusicChatbotUpdated extends MusicChatbotState {
  final List<Map<String, String>> messages;

  MusicChatbotUpdated(this.messages);
}

class MusicChatbotError extends MusicChatbotState {
  final String errorMessage;
  final List<Map<String, String>> messages;

  MusicChatbotError(this.errorMessage, [this.messages = const []]);
}
