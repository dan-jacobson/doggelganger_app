import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:doggelganger/models/dog_data.dart';
import 'package:doggelganger/config/environment.dart';

class ApiService {
  static String get baseUrl => Environment.apiUrl;

  static Future<void> warmUp() async {
    try {
      await http.get(Uri.parse(baseUrl));
    } catch (e) {
      log("Warm-up call failed: $e");
    }
  }

  static Future<(DogData, List<double>)> uploadImageAndGetMatch(
      String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/embed'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath,
        // TODO(drj): is it always a jpg?
        contentType: MediaType('image', 'jpeg')));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var decodedData = json.decode(responseBody);
      if (decodedData.containsKey("result") &
          (decodedData.containsKey("embedding"))) {
        return (
          DogData.fromJson(decodedData['result']),
          List<double>.from(decodedData['embedding']),
        );
      } else {
        // TODO(drj): specify which of these is missing
        throw Exception('API returned response missing result or embedding.');
      }
    } else {
      throw Exception(
          'Failed to get a match. Status code: ${response.statusCode}. Response: $responseBody');
    }
  }

  static Future<bool> logMatch({
    required String dogId,
    required List<double>? dogEmbedding,
    required List<double> userEmbedding,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/log-match'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dogId': dogId,
          'dogEmbedding': dogEmbedding,
          'userEmbedding': userEmbedding,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        log('Failed to log match: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error logging match: $e');
      return false;
    }
  }
}
