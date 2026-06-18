import 'dart:convert';
import 'package:flutter/services.dart';

class Quote {
  final String quote;
  final String author;
  final String source;

  Quote({required this.quote, required this.author, required this.source});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      quote: json['quote'] ?? '',
      author: json['author'] ?? 'Unknown',
      source: json['source'] ?? 'Unknown Source',
    );
  }

  static Future<List<Quote>> loadQuotesFromJson(String assetPath) async {
    final String response = await rootBundle.loadString(assetPath);

    final data = json.decode(response);

    if (data['quotes'] == null) {
      throw Exception("Quotes key is missing in the JSON file");
    }

    return (data['quotes'] as List)
        .map((quoteJson) => Quote.fromJson(quoteJson))
        .toList();
  }
}
