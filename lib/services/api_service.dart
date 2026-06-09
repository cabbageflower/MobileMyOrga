import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // PENTING: Ganti URL di bawah ini dengan IP lokal komputer kamu (contoh: 192.168.1.5)
  static const String baseUrl = 'http://192.168.101.72:8000/api';
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_name', data['user']['full_name']);
        
        return {
          'success': true,
          'role': data['user']['role'],
          'message': 'Login berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal. Periksa kembali kredensial Anda.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan HP dan Laptop terhubung di WiFi yang sama, dan ganti IP di api_service.dart.',
      };
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<Map<String, dynamic>> getHomeData() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getEvents({String filter = 'all'}) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events?filter=$filter'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data kegiatan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getEventDetails(int eventId) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil detail kegiatan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> submitAttendance(int eventId, double lat, double lon) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/attend'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': lat,
          'longitude': lon,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Absensi berhasil',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal melakukan absensi',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, String> data, {String? imagePath}) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/update'));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Tambahkan data teks
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      // Tambahkan foto jika ada
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_photo', imagePath));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update user_name if full_name was updated
        if (responseData['user'] != null && responseData['user']['full_name'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', responseData['user']['full_name']);
        }
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profil berhasil diperbarui',
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getMembers() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/members'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data anggota',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getMemberDetails(int memberId) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/members/$memberId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil detail anggota',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        // Abaikan error saat logout
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_name');
  }

  static Future<Map<String, dynamic>> updateFcmToken(String token) async {
    final authToken = await getToken();
    if (authToken == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'device_type': 'android'
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Token FCM diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui token',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'message': 'Tidak ada sesi aktif'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil notifikasi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server',
      };
    }
  }
}
