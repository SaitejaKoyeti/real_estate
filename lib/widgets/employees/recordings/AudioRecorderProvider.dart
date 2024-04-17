import 'package:flutter/foundation.dart';

class AudioRecorderProvider extends ChangeNotifier {
  bool isRecording = false;

  void toggleRecording() {
    if (isRecording) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void startRecording() {
    isRecording = true;
    notifyListeners();
    // Add your logic to start recording
  }

  void stopRecording() {
    isRecording = false;
    notifyListeners();
    // Add your logic to stop recording
  }
}
