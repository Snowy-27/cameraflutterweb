import 'package:flutter/material.dart';

class PreviewImage extends StatefulWidget {
  const PreviewImage({Key? key, required this.photoBytes}) : super(key: key);
  final photoBytes;

  @override
  _PreviewImageState createState() => _PreviewImageState();
}

class _PreviewImageState extends State<PreviewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview Image',
        ),
      ),
      body: Column(
        children: [
          Image.memory(widget.photoBytes!),
        ],
      ),
    );
  }
}
