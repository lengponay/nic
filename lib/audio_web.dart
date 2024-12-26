// audio_web.dart
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'package:record/record.dart';
import 'firebase_storage.dart';

mixin AudioRecorderMixin {
  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) {
    return recorder.start(config, path: '');
  }

  Future<void> recordStream(AudioRecorder recorder, RecordConfig config) async {
    final bytes = <int>[];
    final stream = await recorder.startStream(config);
    
    stream.listen(
      (data) => bytes.addAll(data),
      onDone: () async {
        final blobUrl = web.URL.createObjectURL(
          web.Blob(<JSUint8Array>[Uint8List.fromList(bytes).toJS].toJS),
        );
        await uploadToFirebase(blobUrl);
      },
    );
  }

  Future<String?> uploadToFirebase(String blobUrl) async {
    return await FirebaseStorageService.uploadAudioFile(blobUrl);
  }

  String createBlobUrl(Uint8List audioData) {
    return web.URL.createObjectURL(
      web.Blob(<JSUint8Array>[audioData.toJS].toJS),
    );
  }
}
