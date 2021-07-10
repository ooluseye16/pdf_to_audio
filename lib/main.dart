import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as imglib;

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
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      print(result.files.single.path!);
      return result.files.single.path!;
    }
  }

  Future<List<File>> getImagesFromPdf(String filePath) async {
    List<File> imagesFromPdf = [];

    final doc = await PdfDocument.openFile(filePath);
    final pages = doc.pageCount;
    // List<imglib.Image> images = [];
// get images from all the pages
    final documentDirectory = await getExternalStorageDirectory();

    for (int i = 1; i <= pages; i++) {
      var page = await doc.getPage(i);
      var imgPDF = await page.render();
      var img = await imgPDF.createImageDetached();
      var imgBytes = await img.toByteData(format: ImageByteFormat.png);
      var libImage = imglib.decodeImage(imgBytes!.buffer
          .asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes));
      File imgFile = new File('${documentDirectory!.path}/abc$i.jpg');
      File file = await new File(imgFile.path)
          .writeAsBytes(imglib.encodeJpg(libImage!));
      imagesFromPdf.add(file);
    }
    print(imagesFromPdf);
    return imagesFromPdf;
  }

  List<File>? imageList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  imageList = await pickFile()
                      .then((value) => getImagesFromPdf(value!));
                  // print(filePath);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.teal,
                  ),
                  child: Center(
                    child: Text("Pick Pdf"),
                  ),
                ),
              ),
              imageList!.isNotEmpty
                  ? Wrap(
                      children: List.generate(
                          imageList!.length,
                          (index) => Container(
                              padding: EdgeInsets.only(right: 10.0),
                              height: 100,
                              width: 50,
                              child: Image.file(imageList![index]))),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
