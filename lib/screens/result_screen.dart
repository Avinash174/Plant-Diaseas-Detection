import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:plant_disease_detection_app/%20utils/labels.dart';
import '../services/ml_service.dart';

class ResultScreen extends StatefulWidget {
  final File image;
  const ResultScreen({super.key, required this.image});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final MLService _mlService = MLService();
  String _disease = "Detecting...";
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _runDetection();
  }

  Future<void> _runDetection() async {
    await _mlService.loadModel();
    final scores = _mlService.predict(widget.image);

    final maxScore = scores.reduce(max);
    final index = scores.indexOf(maxScore);

    setState(() {
      _disease = labels[index];
      _confidence = maxScore * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.file(widget.image, height: 200),
            const SizedBox(height: 20),
            Text(
              _disease,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${_confidence.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Scan Another Leaf'),
            ),
          ],
        ),
      ),
    );
  }
}
