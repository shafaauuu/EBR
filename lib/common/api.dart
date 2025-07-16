import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Get the appropriate base URL depending on the platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    // For Android devices
    else if (Platform.isAndroid) {
      return 'http://192.104.202.147:8000/api';
    }
    // For iOS devices
    else if (Platform.isIOS) {
      return 'http://192.104.202.147:8000/api';
    } 
    // Fallback
    else {
      return 'http://127.0.0.1:8000/api';
    }
  }
}

class Api {
  static Map<String, String> buildHeader() {
    final storage = GetStorage();
    var headers = {
      "Content-Type": "application/json",
    };
    String? token = storage.read("auth_token");
    if(token != null) {
        headers["Authorization"] = "Bearer $token";
     }
    return headers;
  }
  
  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    print('GET Request to: $url');
    try {
      final response = await http.get(url, headers: buildHeader());
      print('GET Response status: ${response.statusCode}');
      print('GET Response body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('GET request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('GET Error: $e');
      throw e;
    }
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    print('POST Request to: $url');
    print('POST Request body: $body');
    
    try {
      final response = await http.post(
        url,
        headers: buildHeader(),
        body: json.encode(body),
      );
      
      print('POST Response status: ${response.statusCode}');
      print('POST Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('POST request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('POST Error: $e');
      throw e;
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    print('PUT Request to: $url');
    print('PUT Request body: $body');
    
    try {
      final response = await http.put(
        url,
        headers: buildHeader(),
        body: json.encode(body),
      );
      
      print('PUT Response status: ${response.statusCode}');
      print('PUT Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('PUT request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('PUT Error: $e');
      throw e;
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    print('PATCH Request to: $url');
    print('PATCH Request body: $body');
    
    try {
      final response = await http.patch(
        url,
        headers: buildHeader(),
        body: json.encode(body),
      );
      
      print('PATCH Response status: ${response.statusCode}');
      print('PATCH Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('PATCH request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('PATCH Error: $e');
      throw e;
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    print('DELETE Request to: $url');
    
    try {
      final response = await http.delete(
        url,
        headers: buildHeader(),
      );
      
      print('DELETE Response status: ${response.statusCode}');
      print('DELETE Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      } else {
        throw Exception('DELETE request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DELETE Error: $e');
      throw e;
    }
  }
}
