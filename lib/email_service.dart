import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Untuk mendeteksi platform
import 'package:http/http.dart' as http; // Untuk HTTP request

class EmailService {
  static Future<bool> sendAudioEmail({
    required String userName,
    required String recipientEmail,
    required String userSubject,
    required String userMessage,
    required String audioFilePath,
  }) async {
    try {
      const String serviceId = 'service_2opkv0p'; 
      const String templateId = 'template_zp8e9h5'; 
      const String userId = '7TuPqzAsANRTuH5iN'; 

      String base64Audio = '';
      if ( audioFilePath.startsWith('blob:')) {
        final response = await http.get(Uri.parse(audioFilePath));

        if (response.statusCode == 200) {
          final Uint8List audioBytes = response.bodyBytes;
          base64Audio = base64Encode(audioBytes);
        } else {
          debugPrint('Failed to fetch blob: ${response.statusCode}');
          return false;
        }
      } else {
        debugPrint('Invalid audio file URL');
        return false;
      }

      final Map<String, dynamic> emailData = {
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': userName,
          'recipient_email': recipientEmail,
          'user_subject': userSubject,
          'user_message': userMessage,
        'attachments': base64Audio,
        },
      };

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailData),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully');
        return true;
      } else {
        debugPrint('Failed to send email: ${response.body}');
        return false;
      }
    } catch (e, s) {
      debugPrint('Error sending email: $e $s');
      return false;
    }
  }
}
