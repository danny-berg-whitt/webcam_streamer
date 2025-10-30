// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/stream_info_panel.dart';
// import '../widgets/control_panel.dart';
import '../services/stream_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StreamService _streamService = StreamService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    _checkStreamStatus();
  }

  Future<void> _checkStreamStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAvailable = await _streamService.checkStreamAvailability();
      if (!isAvailable) {
        setState(() {
          _errorMessage = 'Stream is not currently available';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking stream: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 1200;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : isWideScreen
                          ? _buildWideLayout()
                          : _buildNarrowLayout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.videocam,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Text(
            'Webcam Live Stream',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(_showInfo ? Icons.info : Icons.info_outline),
            onPressed: () {
              setState(() {
                _showInfo = !_showInfo;
              });
            },
            tooltip: 'Stream Info',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStreamStatus,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: VideoPlayerWidget(
              streamUrl: _streamService.hlsStreamUrl,
            ),
          ),
        ),
        if (_showInfo)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamInfoPanel(
                streamService: _streamService,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VideoPlayerWidget(
              streamUrl: _streamService.hlsStreamUrl,
            ),
            if (_showInfo) ...[
              const SizedBox(height: 16),
              StreamInfoPanel(
                streamService: _streamService,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Stream Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkStreamStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
