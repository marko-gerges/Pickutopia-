import 'dart:developer';

import 'package:dio/dio.dart';

class MusicChatbotService {
  final Dio _dio;

  MusicChatbotService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://footbath-previous-divisive.ngrok-free.dev',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json','ngrok-skip-browser-warning': 'true',},
            ));

  Future<Map<String, dynamic>> sendQuery(String query) async {
    try {
      log("Sending request with query: $query");

      final response = await _dio.post(
        '/recommendations',
        data: {'query': query},
      );

      log("Response received: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (!data.containsKey('message')) {
          data['message'] = '';
        }

        if (!data.containsKey('recommendations')) {
          data['recommendations'] = <Map<String, dynamic>>[];
        }

        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log("Dio error: ${e.message}");
      log("Response data: ${e.response?.data}");
      log("Response status code: ${e.response?.statusCode}");

      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Server might be down or unreachable.';
      } else if (e.message?.contains('Connection refused') == true) {
        errorMessage =
            'Server is not running or not accessible. Please check the server address and make sure it\'s running.';
      } else {
        errorMessage = 'Network error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      log("Generic error: $e");
      throw Exception('Failed to get response from server: $e');
    }
  }
}
