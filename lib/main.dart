import 'package:flutter/material.dart';
import 'audio_record.dart';

import 'audio_player.dart';
import 'email_service.dart';

class RecordTest extends StatefulWidget {
  const RecordTest({super.key});

  @override
  State<RecordTest> createState() => _RecordTestState();
}

class _RecordTestState extends State<RecordTest> {
  bool showPlayer = false;
  String? audioPath;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showEmailDialog(String filePath) async {
    if (filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio recorded yet')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Audio via Email'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter recipient email',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  return emailRegex.hasMatch(value)
                      ? null
                      : 'Invalid email format';
                },
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Enter email subject',
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Subject is required'
                    : null,
              ),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter your message',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Message is required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final success = await EmailService.sendAudioEmail(
                  userName: _nameController.text,
                  recipientEmail: _emailController.text,
                  userSubject: _subjectController.text,
                  userMessage: _messageController.text,
                  audioFilePath: filePath, 
                );

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Email sent successfully'
                          : 'Failed to send email. Please try again.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showPlayer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Flexible(
                    child: AudioPlayer(
                      source: audioPath!,
                      onDelete: () {
                        setState(() => showPlayer = false);
                      },
                    ),
                  ),
                )
              else
                Flexible(
                  child: Recorder(
                    onStop: (path) {
                      setState(() {
                        audioPath = path;
                        showPlayer = true;
                      });
                    },
                  ),
                ),
              if (showPlayer)
                ElevatedButton(
                  onPressed: () async {
                    if (audioPath != null) {
                      await _showEmailDialog(audioPath!); 
                    } 
                    else 
                    {
                      debugPrint("Audio path is null!");
                    }
                  },
                  child: const Text('Send via Email'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: RecordTest(),
  ));
}

