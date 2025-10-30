// lib/models/stream_config.dart
class StreamConfig {
  final String streamName;
  final String serverAddress;
  final int httpPort;
  final int rtmpPort;
  final String resolution;
  final int frameRate;
  final int bitrate;

  const StreamConfig({
    required this.streamName,
    required this.serverAddress,
    this.httpPort = 30080,
    this.rtmpPort = 31935,
    this.resolution = '1280x720',
    this.frameRate = 30,
    this.bitrate = 2000,
  });

  String get hlsUrl => 'http://$serverAddress:$httpPort/hls/$streamName.m3u8';
  String get dashUrl => 'http://$serverAddress:$httpPort/dash/$streamName.mpd';
  String get rtmpUrl => 'rtmp://$serverAddress:$rtmpPort/live/$streamName';
}
