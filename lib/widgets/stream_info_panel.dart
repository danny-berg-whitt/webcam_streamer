// lib/widgets/stream_info_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/stream_service.dart';
import 'dart:async';

class StreamInfoPanel extends StatefulWidget {
  final StreamService streamService;

  const StreamInfoPanel({
    super.key,
    required this.streamService,
  });

  @override
  State<StreamInfoPanel> createState() => _StreamInfoPanelState();
}

class _StreamInfoPanelState extends State<StreamInfoPanel> {
  Timer? _updateTimer;
  Map<String, dynamic> _streamStats = {};

  @override
  void initState() {
    super.initState();
    _updateStreamInfo();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateStreamInfo(),
    );
  }

  Future<void> _updateStreamInfo() async {
    try {
      final stats = await widget.streamService.getStreamStats();
      if (mounted) {
        setState(() {
          _streamStats = stats;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.1),
        ),
      ),
// Updated _buildInfoItems section in StreamInfoPanel
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem('Stream Name', 'webcam'),
          _buildInfoItem('Protocol', 'HLS'),
          _buildInfoItem('Resolution', '1280x720'),
          _buildInfoItem('Frame Rate', '30 fps'),
          _buildInfoItem('Bitrate', '2000 kbps'),
          _buildInfoItem(
            'Server',
            widget.streamService.serverAddress,
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildSectionTitle('Server Status'),
          if (_streamStats.isNotEmpty) ...[
            _buildInfoItem(
              'Status',
              _streamStats['status'] ?? 'unknown',
            ),
            if (_streamStats['nginx_version'] != null)
              _buildInfoItem(
                'Nginx Version',
                _streamStats['nginx_version'],
              ),
            if (_streamStats['rtmp_version'] != null)
              _buildInfoItem(
                'RTMP Version',
                _streamStats['rtmp_version'],
              ),
            if (_streamStats['uptime'] != null)
              _buildInfoItem(
                'Uptime',
                _streamStats['uptime'],
              ),
            if (_streamStats['clients'] != null)
              _buildInfoItem(
                'Active Clients',
                _streamStats['clients'].toString(),
              ),
            if (_streamStats['bandwidth_in'] != null)
              _buildInfoItem(
                'Bandwidth In',
                _streamStats['bandwidth_in'],
              ),
            if (_streamStats['bandwidth_out'] != null)
              _buildInfoItem(
                'Bandwidth Out',
                _streamStats['bandwidth_out'],
              ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Loading server statistics...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildSectionTitle('Stream URLs'),
          _buildCopyableUrl(
            'HLS',
            widget.streamService.hlsStreamUrl,
          ),
          _buildCopyableUrl(
            'DASH',
            widget.streamService.dashStreamUrl,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCopyableUrl(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    url,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label URL copied to clipboard'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          width: 300,
                        ),
                      );
                    }
                  },
                  tooltip: 'Copy URL',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
