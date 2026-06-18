import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickutopia/features/home/data/quote_model.dart';

part 'quote_state.dart';

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit() : super(QuoteInitial());

  Future<void> loadQuotes() async {
    try {
      emit(QuoteLoading());

      final quotes = await Quote.loadQuotesFromJson('assets/quotes.json');
      final random = Random();
      final Quote randomQuote = quotes[random.nextInt(quotes.length)];
      emit(QuoteLoaded(randomQuote));
    } catch (e) {
      emit(QuoteError("Failed to load quote: $e"));
    }
  }
}
