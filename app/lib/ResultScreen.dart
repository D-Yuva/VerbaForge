import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String videoTitle;
  final String videoDuration;
  final String responseSummary;
  final String responseScript;

  ResultScreen({
    required this.videoTitle,
    required this.videoDuration,
    required this.responseSummary,
    required this.responseScript,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Results'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Video Info'),
              Tab(text: 'Summary'),
              Tab(text: 'Script'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            VideoInfoTab(videoTitle: videoTitle, videoDuration: videoDuration),
            SummaryTab(responseSummary: responseSummary),
            ScriptTab(responseScript: responseScript),
          ],
        ),
      ),
    );
  }
}

class VideoInfoTab extends StatelessWidget {
  final String videoTitle;
  final String videoDuration;

  VideoInfoTab({required this.videoTitle, required this.videoDuration});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Video Title: $videoTitle',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Video Duration: $videoDuration',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class SummaryTab extends StatelessWidget {
  final String responseSummary;

  SummaryTab({required this.responseSummary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(responseSummary),
    );
  }
}

class ScriptTab extends StatelessWidget {
  final String responseScript;

  ScriptTab({required this.responseScript});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Text(responseScript),
    );
  }
}
