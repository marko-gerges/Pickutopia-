abstract class AnimeChatbotState {}

class AnimeChatbotInitial extends AnimeChatbotState {}

class AnimeChatbotLoading extends AnimeChatbotState {
  final List<Map<String, String>> messages;

  AnimeChatbotLoading(this.messages);
}

class AnimeChatbotUpdated extends AnimeChatbotState {
  final List<Map<String, String>> messages;

  AnimeChatbotUpdated(this.messages);
}

class AnimeChatbotError extends AnimeChatbotState {
  final String message;
  final List<Map<String, String>> messages;

  AnimeChatbotError(this.message, this.messages);
}
