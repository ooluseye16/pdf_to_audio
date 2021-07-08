import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PdfToAudioApp(),
    );
  }
}

class PdfToAudioApp extends StatefulWidget {
  const PdfToAudioApp({Key? key}) : super(key: key);

  @override
  _PdfToAudioAppState createState() => _PdfToAudioAppState();
}

class _PdfToAudioAppState extends State<PdfToAudioApp> {
  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return result.files.single.path!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () async {
            String? filePath = await pickFile();
            print(filePath!);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.teal,
            ),
            child: Center(
              child: Text("Pick Pdf"),
            ),
          ),
        ),
      ),
    );
  }
}
