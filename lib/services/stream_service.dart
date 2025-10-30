// lib/services/stream_service.dart
import 'package:http/http.dart' as http;
// import 'dart:convert';

class StreamService {
  // Update these with your actual server address
  // For local testing: 'localhost:30080'
  // For production: your domain or IP
  final String serverAddress = 'localhost:30080';

  String get hlsStreamUrl => 'http://$serverAddress/hls/webcam.m3u8';
  String get dashStreamUrl => 'http://$serverAddress/dash/webcam.mpd';
  String get rtmpStreamUrl => 'rtmp://$serverAddress:31935/live/webcam';
  String get statUrl => 'http://$serverAddress/stat';

  Future<bool> checkStreamAvailability() async {
    try {
      final response = await http
          .head(
            Uri.parse(hlsStreamUrl),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getStreamStats() async {
    try {
      final response = await http
          .get(
            Uri.parse(statUrl),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        // Parse XML response from nginx-rtmp stat page
        // This is a simplified version
        return {
          'status': 'online',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      // Return default stats on error
    }

    return {
      'status': 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
