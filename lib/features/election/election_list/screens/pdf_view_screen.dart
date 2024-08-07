import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  // Constructor
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    // Parse the JSON string
    var jsonList = json.decode(pdfUrl);

    // Check if jsonList is a non-empty list of objects
    if (jsonList is List && jsonList.isNotEmpty) {
      // Extract the first object from the list
      var firstObject = jsonList[0];

      // Extract the URL from the object
      var url = firstObject['file'];

      // Print the extracted URL for debugging
      print('PDF URL: $url');

      // Return the Scaffold with PDFView
      return Scaffold(
        appBar: AppBar(
          title: const Text('PDF Viewer'),
        ),
        body: SfPdfViewer.network(
          url,
        ),
      );
    } else {
      // Handle the case where jsonList is not a valid structure
      print('Invalid JSON structure for PDF URL');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Invalid JSON structure for PDF URL'),
        ),
      );
    }
  }
}
