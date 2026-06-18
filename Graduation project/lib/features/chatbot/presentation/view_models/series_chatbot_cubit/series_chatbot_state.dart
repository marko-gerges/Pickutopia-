abstract class TvShowsChatbotState {
  const TvShowsChatbotState();
}

class TvShowsChatbotInitial extends TvShowsChatbotState {}

class TvShowsChatbotLoading extends TvShowsChatbotState {
  final List<Map<String, String>> messages;

  const TvShowsChatbotLoading({required this.messages});
}

class TvShowsChatbotUpdated extends TvShowsChatbotState {
  final List<Map<String, String>> messages;
  final List<String> recommendations;

  const TvShowsChatbotUpdated({
    required this.messages,
    required this.recommendations,
  });
}

class TvShowsChatbotError extends TvShowsChatbotState {
  final String errorMessage;
  final List<Map<String, String>> messages;

  const TvShowsChatbotError({
    required this.errorMessage,
    required this.messages,
  });
}