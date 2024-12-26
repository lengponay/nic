// firebase_storage_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadAudioFile(String blobUrl) async {
    try {
      final response = await http.get(Uri.parse(blobUrl));
      if (response.statusCode != 200) {
        debugPrint('Failed to fetch blob: ${response.statusCode}');
        return null;
      }

      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final storageRef = _storage.ref().child('audio_recordings/$fileName');

      final uploadTask = storageRef.putData(
        response.bodyBytes,
        SettableMetadata(contentType: 'audio/wav'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Audio uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e, s) {
      debugPrint('Error uploading audio to Firebase: $e $s');
      return null;
    }
  }
}
