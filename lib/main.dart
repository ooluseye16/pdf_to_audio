import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
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

  final textDetector = GoogleMlKit.vision.textDetector();

  Future<List<Map<String, dynamic>>> getImagesFromPdf(String filePath) async {
    // List<Image> imagesFromPdf = [];
    // List<String> textFromImage = [];
    List<Map<String, dynamic>> imagesAndTextFromPDF = [];
    //open the pdf document
    final doc = await PdfDocument.openFile(filePath);
    //get number of pages the pdf has
    final pages = doc.pageCount;
    //create a directory to add the file images
    final documentDirectory = await getExternalStorageDirectory();

    //get the images and text from each page of the pdf
    for (int i = 1; i <= pages; i++) {
      var page = await doc.getPage(i);
      var imgPDF = await page.render();
      var img = await imgPDF.createImageDetached();
      var imgBytes = await img.toByteData(format: ImageByteFormat.png);
      var libImage = imglib.decodeImage(imgBytes!.buffer
          .asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes));
      //create a saved-to-dirctory file
      File imgFile = new File('${documentDirectory!.path}/abc$i.jpg');

      //write the image into the created file
      File file = await new File(imgFile.path)
          .writeAsBytes(imglib.encodeJpg(libImage!));
      final inputImage = InputImage.fromFile(file);
//get the text from the image
      final RecognisedText recognisedText =
          await textDetector.processImage(inputImage);
      // imagesFromPdf.add(Image.file(file));
      // textFromImage.add(recognisedText.text);

      //add the image and text to a list.
      imagesAndTextFromPDF.add(
        {
          "file": Image.file(file),
          "text": recognisedText.text,
        },
      );
      setState(() {});
    }
    //print(imagesFromPdf);
    return imagesAndTextFromPDF;
  }

  List<Map<String, dynamic>>? imageAndTextList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30.0,
              ),
              InkWell(
                onTap: () async {
                  imageAndTextList = await pickFile()
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
              imageAndTextList!.isNotEmpty
                  ? Column(
                      children: List.generate(
                        imageAndTextList!.length,
                        (index) => Container(
                          padding: EdgeInsets.only(
                              right: 10.0, bottom: 20.0, left: 10.0),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: imageAndTextList![index]['file'],
                              ),
                              Expanded(
                                child: Text(
                                  imageAndTextList![index]['text'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
