# README.md

# Webcam Streaming Flutter Web App

A Flutter web application for viewing HLS/DASH streams from an RTMP server deployed on Kubernetes.

Note: The initial implementation was [generated](https://claude.ai/share/992bf6be-f64f-43e8-b0fc-9334f19e7ffa)
using [Claude Sonnet 4.5](https://claude.ai). 

## Features

- **Live HLS Video Streaming**: View webcam stream using HLS protocol
- **Responsive Design**: Works on desktop and mobile browsers
- **Video Controls**: Play/pause, volume control, mute
- **Stream Information Panel**: View stream details and URLs
- **Error Handling**: Graceful error handling with retry options
- **Modern UI**: Clean, dark-themed interface

## Prerequisites

- Flutter SDK (>=3.0.0)
- A running Kubernetes cluster with the RTMP server deployed
- Access to the NodePort services (30080 for HTTP, 31935 for RTMP)

## Setup

1. **Clone or create the project**

2. **Update server address**
   Edit `lib/services/stream_service.dart` and update the `serverAddress`:
```dart
   final String serverAddress = 'your-server-ip:30080';
```

3. **Install dependencies**
```bash
   flutter pub get
```

4. **Run the app**
```bash
   flutter run -d chrome --web-port=8080
```

## Configuration

### Server Connection

Update the server address in `lib/services/stream_service.dart`:

- For local development: `localhost:30080`
- For production: Use your Kubernetes node IP or domain

### Stream URLs

The app automatically generates URLs based on your configuration:
- **HLS**: `http://server:30080/hls/webcam.m3u8`
- **DASH**: `http://server:30080/dash/webcam.mpd`
- **RTMP**: `rtmp://server:31935/live/webcam`

## Building for Production
```bash
flutter build web --release
```

The built files will be in `build/web/` directory.

## Deployment

### Deploy to a Web Server
```bash
# Build the app
flutter build web --release

# Copy to your web server
cp -r build/web/* /var/www/html/
```

### Deploy to Firebase Hosting
```bash
firebase init hosting
firebase deploy
```

## Troubleshooting

### Stream Not Loading

1. Check if the RTMP server is running
2. Verify NodePort services are accessible
3. Check browser console for CORS errors
4. Ensure the webcam is streaming to the RTMP server

### CORS Issues

The nginx configuration in the Kubernetes deployment already includes CORS headers. If you still have issues:

1. Check nginx logs: `kubectl logs <pod-name>`
2. Verify the CORS headers in the nginx config

### Performance Issues

- Reduce video quality in the ffmpeg configuration
- Lower the bitrate in the Kubernetes deployment
- Use a CDN for better distribution

## License

[MIT License](LICENSE)
