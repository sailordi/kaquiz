import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class BackendAdapter {
  late final String baseUrl;

  BackendAdapter(int port) {
    // Check if the app is running on Android
    if (Platform.isAndroid) {
      // Use 10.0.2.2 for Android emulator to connect to the localhost of the host machine
      baseUrl = 'http://10.0.2.2:$port';
    } else if (Platform.isIOS) {
      // Use localhost for iOS simulator
      baseUrl = 'http://localhost:$port';
    } else {
      // Default (you can extend this logic for other platforms or use a remote URL)
      baseUrl = 'http://localhost:$port';
    }

  }

  Future<String> authenticateUser(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id_token': idToken,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['access_token'];
    } else {
      throw Exception('Failed to authenticate user');
    }
  }

  Future<void> updateUser(String token, String name, String avatar) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'avatar': avatar,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> submitLocation(String token, double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/locations'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode(<String, double>{
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit location');
    }
  }

}