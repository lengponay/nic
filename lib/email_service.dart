// email_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  static Future<bool> sendAudioEmail({
    required String userName,
    required String recipientEmail,
    required String userSubject,
    required String userMessage,
    required String downloadUrl,
  }) async {
    try {
    
      const String serviceId = 'service_2opkv0p';
      const String templateId = 'template_zp8e9h5';
      const String userId = '7TuPqzAsANRTuH5iN';

      final Map<String, dynamic> emailData = {
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': userName,
          'recipient_email': recipientEmail,
          'user_subject': userSubject,
          'user_message': userMessage,
          'audio_url': downloadUrl,
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
