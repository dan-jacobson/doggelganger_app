import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doggelganger_app/models/dog_data.dart';
import 'package:doggelganger_app/config/environment.dart';

class ApiService {
  static String get baseUrl => Environment.apiUrl;

  static Future<DogData> uploadImageAndGetMatch(String imagePath) async {
    try {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/embed'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    print('Sending request to: ${request.url}');                                                                                                          
    print('Request headers: ${request.headers}');                                                                                                         
    print('Request fields: ${request.fields}');

    var response = await request.send();                                                                                                                  
    var responseBody = await response.stream.bytesToString();                                                                                             
                                                                                                                                                          
    print('Response status code: ${response.statusCode}');                                                                                                
    print('Response body: $responseBody');                                                                                                                
                                                                                                                                                          
    if (response.statusCode == 200) {                                                                                                                     
      var decodedData = json.decode(responseBody);                                                                                                        
                                                                                                                                                          
      if (decodedData.containsKey("result")) {                                                                                                            
        return DogData.fromJson(decodedData['result']);                                                                                                   
      } else {                                                                                                                                            
        throw Exception('No similar images found in the response');                                                                                       
      }                                                                                                                                                   
    } else {                                                                                                                                              
      throw Exception(                                                                                                                                    
          'Failed to get a match. Status code: ${response.statusCode}. Response: $responseBody');                                                         
    }                                                                                                                                                     
  } catch (e) {                                                                                                                                           
    print('Error in uploadImageAndGetMatch: $e');                                                                                                         
    rethrow;                                                                                                                                              
  }                                                                                                                                                       
}                                                                                                                                                         
}
