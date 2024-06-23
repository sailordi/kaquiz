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
      print("authenticateUser error: ${response.body}");
      return jsonDecode(response.body)['access_token'];
    } else {
      print("authenticateUser: ${response.body}");
    }
    return "";
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
      //TODO error updateUser
      print("error updateUser: ${response.body}");
      throw Exception('Failed to update user');
    }
  }

  Future<void> submitLocation(String token,double latitude,double longitude) async {
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
      //TODO error submitLocatio
      print("error submitLocation: ${response.body}");
    }
    else {
      print("submitLocation: ${response.body}");
    }

  }

  Future<void> getInvites(String accessToken,int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/invites/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
      },
    );

    if (response.statusCode == 200) {
      //TODO data parsing getInvites
      print("getInvites: ${response.body}");
    } else {
        //TODO error getInvites
        print("error getInvites: ${response.body}");
    }

  }

  Future<void> declineInvite(String accessToken, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/invites/$userId/decline'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
      },
    );

    if (response.statusCode != 200) {
      //TODO error declineInvite
      print("error declineInvite: ${response.body}");
    }
    else {
      print("declineInvite: ${response.body}");
    }

  }

  Future<void> acceptInvite(String accessToken, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/invites/$userId/accept'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
      },
    );

    if (response.statusCode != 200) {
      //TODO error acceptInvite
      print("error acceptInvite: ${response.body}");
    }
    else {
      print("acceptInvite: ${response.body}");
    }

  }

  Future<void> deleteFriend(String accessToken, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/friends/$id'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
      },
    );

    if (response.statusCode != 200) {
      //TODO error deleteFriend
      print("error deleteFriend: ${response.body}");
    }else {
      print("deleteFriend: ${response.body}");
    }

  }

  Future<void> getFriendsLocations(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/friends'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': accessToken,
      },
    );

    if (response.statusCode == 200) {
      //TODO parse data getFriendsLocations
      print("getFriendsLocations: ${response.body}");
    } else {
      //TODO error getFriendsLocations
      print("error getFriendsLocations: ${response.body}");
    }
  }

}