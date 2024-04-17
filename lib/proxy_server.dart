import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

void main() async {
  final server = await HttpServer.bind('localhost', 57630);
  print('Proxy server is running on ${server.address}:${server.port}');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      handleWebSocket(request);
    } else {
      handleHttpRequest(request);
    }
  }
}

void handleHttpRequest(HttpRequest request) async {
  final String imageUrl = request.uri.queryParameters['imageUrl'] ?? '';
  final String storageUrl = 'https://firebasestorage.googleapis.com/$imageUrl';

  try {
    final response = await http.get(Uri.parse(storageUrl));

    if (response.statusCode == 200) {
      final Uint8List imageData = response.bodyBytes;
      final ContentType contentType = ContentType.parse(response.headers['content-type'] ?? 'application/octet-stream');

      request.response
        ..headers.contentType = contentType
        ..statusCode = response.statusCode
        ..add(imageData)
        ..close();
    } else {
      request.response
        ..statusCode = response.statusCode
        ..write(jsonEncode({'error': 'Failed to fetch image. Status code: ${response.statusCode}'}))
        ..close();
    }
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to fetch image. Exception: $e'}))
      ..close();
  }
}

void handleWebSocket(HttpRequest request) {
  WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
    webSocket.listen((data) {
      // Handle WebSocket data if needed
    }, onDone: () {
      // Handle WebSocket closed
    });
  });
}
