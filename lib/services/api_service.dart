import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doggelganger_app/models/dog_data.dart';

class ApiService {
  static const String baseUrl = 'http://0.0.0.0:8000'; // FastAPI server running locally

  static Future<DogData> uploadImageAndGetMatch(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/embed'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = json.decode(responseData);
      var bestResponse = decodedData['similar_images'][0];
      return DogData.fromJson({
        ...bestResponse['metadata'],
        'image_url': bestResponse['image_url'],
      });
    } else {
      throw Exception('Failed to get a match. Status code: ${response.statusCode}');
    }
  }
}
