import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:doggelganger/models/dog_data.dart';
import 'package:doggelganger/config/environment.dart';

class ApiService {
  static String get baseUrl => Environment.apiUrl;

  static Future<DogData> uploadImageAndGetMatch(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/embed'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath,
        // TODO(drj): is it always a jpg?
        contentType: MediaType('image', 'jpeg')));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var decodedData = json.decode(responseBody);
      if (decodedData.containsKey("result")) {
        return DogData.fromJson(decodedData['result']);
      } else {
        throw Exception('API returned empty result.');
      }
    } else {
      throw Exception(
          'Failed to get a match. Status code: ${response.statusCode}. Response: $responseBody');
    }
  }
}
