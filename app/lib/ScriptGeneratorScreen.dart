import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ResultScreen.dart';

class ScriptGeneratorScreen extends StatefulWidget {
  @override
  _ScriptGeneratorScreenState createState() => _ScriptGeneratorScreenState();
}

class _ScriptGeneratorScreenState extends State<ScriptGeneratorScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _scriptTimeController = TextEditingController();
  final TextEditingController _culturalReferenceController =
      TextEditingController();
  final TextEditingController _specificInputController =
      TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchScript() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = _urlController.text;
    final scriptTime = _scriptTimeController.text;
    final culturalReference = _culturalReferenceController.text;
    final specificInput = _specificInputController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/process_video'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'url': url,
          'script_time': scriptTime,
          'cultural_reference': culturalReference,
          'specific_input': specificInput,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              videoTitle: data['video_title'],
              videoDuration: data['video_duration'],
              responseSummary: data['response_summary'],
              responseScript: data['response_script'],
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = data['error'];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Script Generator'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
              ),
            ),
            TextField(
              controller: _scriptTimeController,
              decoration: InputDecoration(
                labelText: 'Script Time (in minutes)',
              ),
            ),
            TextField(
              controller: _culturalReferenceController,
              decoration: InputDecoration(
                labelText: 'Cultural Reference',
              ),
            ),
            TextField(
              controller: _specificInputController,
              decoration: InputDecoration(
                labelText: 'Inputs',
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: fetchScript,
                    child: Text('Generate Script'),
                  ),
            SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
