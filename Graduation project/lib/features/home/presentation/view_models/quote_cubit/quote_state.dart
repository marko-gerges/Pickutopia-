part of 'quote_cubit.dart';

abstract class QuoteState {}

final class QuoteInitial extends QuoteState {}

final class QuoteLoading extends QuoteState {}

final class QuoteLoaded extends QuoteState {
  final Quote quote;

  QuoteLoaded(this.quote);
}

final class QuoteError extends QuoteState {
  final String message;

  QuoteError(this.message);
}
