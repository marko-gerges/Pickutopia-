import 'dart:developer';
import 'package:dio/dio.dart';

class SeriesChatbotService {
  final Dio _dio;
// http://192.168.1.7:5003
  SeriesChatbotService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://custodian-spring-sulk.ngrok-free.dev',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'ngrok-skip-browser-warning': 'true',
                },
              ),
            );

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      log("Sending message: $message");

      final response = await _dio.post(
        '/series_chatbot',
        data: {'message': message},
      );

      log("Response received: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['response'] is String) {
          return {
            'message': data['response'],
            'recommendations': <String>[],
          };
        } else if (data['response'] is Map<String, dynamic>) {
          final resp = data['response'];
          return {
            'message': 'Here are some series similar to "${resp['movie']}":',
            'recommendations': List<String>.from(resp['recommendations']),
          };
        } else {
          return {
            'message': 'Unexpected response format.',
            'recommendations': <String>[],
          };
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log("Dio error: ${e.message}");
      log("Response data: ${e.response?.data}");
      log("Status code: ${e.response?.statusCode}");

      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Server might be down or unreachable.';
      } else if (e.message?.contains('Connection refused') == true) {
        errorMessage =
            'Server is not running or not accessible. Please check the server address.';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      log("Unexpected error: $e");
      throw Exception('Failed to communicate with series chatbot: $e');
    }
  }
}
