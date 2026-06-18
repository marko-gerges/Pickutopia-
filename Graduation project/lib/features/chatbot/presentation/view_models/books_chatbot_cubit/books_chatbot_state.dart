abstract class BookChatbotState {}

class BookChatbotInitial extends BookChatbotState {}

class BookChatbotLoading extends BookChatbotState {
  final List<Map<String, String>> messages;

  BookChatbotLoading([this.messages = const []]);
}

class BookChatbotUpdated extends BookChatbotState {
  final List<Map<String, String>> messages;

  BookChatbotUpdated(this.messages);
}

class BookChatbotError extends BookChatbotState {
  final String errorMessage;
  final List<Map<String, String>> messages;

  BookChatbotError(this.errorMessage, [this.messages = const []]);
}
