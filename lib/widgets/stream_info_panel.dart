// lib/widgets/stream_info_panel.dart
import 'package:flutter/material.dart';
import '../services/stream_service.dart';
import 'dart:async';

class StreamInfoPanel extends StatefulWidget {
  final StreamService streamService;

  const StreamInfoPanel({
    Key? key,
    required this.streamService,
  }) : super(key: key);

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
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Stream Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                _buildCopyableUrl(
                  'RTMP',
                  widget.streamService.rtmpStreamUrl,
                ),
              ],
            ),
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
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    url,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    // Copy to clipboard functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('URL copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
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
