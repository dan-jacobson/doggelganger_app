import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doggelganger_app/models/dog_data.dart';

class ApiService {
  static const String baseUrl = 'https://serve-371619654395.us-east4.run.app'; // FastAPI server running locally

  static Future<DogData> uploadImageAndGetMatch(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/embed'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = json.decode(responseData);
      
      if (decodedData['similar_image'] != null && decodedData['similar_image'].isNotEmpty) {
        var bestMatch = decodedData['similar_image'];
        return DogData.fromJson({
          ...bestMatch['metadata'],
          'imageURL': bestMatch['image_url'],
        });
      } else {
        throw Exception('No similar images found in the response');
      }
    } else {
      throw Exception('Failed to get a match. Status code: ${response.statusCode}');
    }
  }
}
