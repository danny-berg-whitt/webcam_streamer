import 'package:http/http.dart' as http;

class StreamService {
  final String serverAddress = 'fishcam.berg-whitt.com';

  String get hlsStreamUrl => 'https://$serverAddress/hls/stream/index.m3u8';
  String get dashStreamUrl => 'http:s//$serverAddress/dash/stream.mpd';
  String get statUrl => 'https://$serverAddress/stat';

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
        final xmlContent = response.body;

        // Extract key information using simple string parsing
        // For production, consider using an XML parser package
        final stats = <String, dynamic>{
          'status': 'online',
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Extract nginx version
        final nginxVersionMatch = RegExp(r'<nginx_version>(.*?)</nginx_version>').firstMatch(xmlContent);
        if (nginxVersionMatch != null) {
          stats['nginx_version'] = nginxVersionMatch.group(1);
        }

        // Extract rtmp version
        final rtmpVersionMatch = RegExp(r'<nginx_rtmp_version>(.*?)</nginx_rtmp_version>').firstMatch(xmlContent);
        if (rtmpVersionMatch != null) {
          stats['rtmp_version'] = rtmpVersionMatch.group(1);
        }

        // Extract uptime
        final uptimeMatch = RegExp(r'<uptime>(.*?)</uptime>').firstMatch(xmlContent);
        if (uptimeMatch != null) {
          final uptimeSeconds = int.tryParse(uptimeMatch.group(1) ?? '0') ?? 0;
          stats['uptime'] = _formatUptime(uptimeSeconds);
          stats['uptime_seconds'] = uptimeSeconds;
        }

        // Extract number of clients
        final clientsMatch = RegExp(r'<nclients>(.*?)</nclients>').firstMatch(xmlContent);
        if (clientsMatch != null) {
          stats['clients'] = int.tryParse(clientsMatch.group(1) ?? '0') ?? 0;
        }

        // Extract bandwidth
        final bwInMatch = RegExp(r'<bw_in>(.*?)</bw_in>').firstMatch(xmlContent);
        if (bwInMatch != null) {
          final bwIn = int.tryParse(bwInMatch.group(1) ?? '0') ?? 0;
          stats['bandwidth_in'] = _formatBandwidth(bwIn);
        }

        final bwOutMatch = RegExp(r'<bw_out>(.*?)</bw_out>').firstMatch(xmlContent);
        if (bwOutMatch != null) {
          final bwOut = int.tryParse(bwOutMatch.group(1) ?? '0') ?? 0;
          stats['bandwidth_out'] = _formatBandwidth(bwOut);
        }

        return stats;
      }
    } catch (e) {
      print('Error fetching stream stats: $e');
    }

    return {
      'status': 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _formatUptime(int seconds) {
    final duration = Duration(seconds: seconds);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatBandwidth(int bytesPerSecond) {
    if (bytesPerSecond == 0) return '0 B/s';

    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    int unitIndex = 0;
    double value = bytesPerSecond.toDouble();

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}
