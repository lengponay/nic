import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

      File audioFile = File(audioFilePath);
      
      if (!await audioFile.exists()) {
        debugPrint('Audio file does not exist');
        return false;
      }

      List<int> audioBytes = await audioFile.readAsBytes();
      String base64Audio = base64Encode(audioBytes);

      final Map<String, dynamic> emailData = {
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': userName,
          'recipient_email': recipientEmail,
          'user_subject': userSubject,
          'user_message': userMessage,
        },
        'attachments': [
          {
            'name': 'audio.wav',  
            'data': base64Audio,
          },
        ],
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
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }
}
