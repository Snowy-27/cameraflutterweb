import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:webcamtest/preview.dart';

void main() {
  // ignore: undefined_prefixed_name

  final VideoElement video = VideoElement();
  final CanvasElement canvas = CanvasElement();
  ui.platformViewRegistry
      .registerViewFactory('video-view', (int viewId) => video);

  runApp(MaterialApp(
    home: HomePage(
      video: video,
      canvas: canvas,
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.video, this.canvas}) : super(key: key);

  final video;
  final canvas;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var initialized = false;
  Uint8List? photoBytes;
  var access = false;

  void requestCamera() async {
    while (!initialized) {
      try {
        final mediaStream = await window.navigator.mediaDevices!
            .getUserMedia({'video': true, 'audio': false});
        widget.video.srcObject = mediaStream;
        await widget.video.play();
        setState(() {
          initialized = true;
          access = true;
        });
      } on DomException catch (e) {
        print('Error: ${e.message}');
      }
    }
    // if (initialized) {
    //   print('Already init');
    //   return true;
    // }
  }

  void takePic(contextd) {
    assert(
      initialized,
    );

    final context = widget.canvas.context2D;

    widget.canvas.width = widget.video.videoWidth;
    widget.canvas.height = widget.video.videoHeight;
    context.drawImage(widget.video, 0, 0);

    final data = widget.canvas.toDataUrl('image/png');
    // print(data);
    final uri = Uri.parse(data);
    // print(uri);
    final bytes = uri.data!.contentAsBytes();
    setState(() {
      photoBytes = bytes;
    });

    Navigator.push(
      contextd,
      MaterialPageRoute(builder: (context) => PreviewImage(photoBytes: bytes)),
    );
  }

  @override
  void initState() {
    super.initState();
    requestCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Web Camera'),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton(
              //     onPressed: () async {
              //       print('Request!');
              //       final success = await requestCamera();
              //       if (!success) {
              //         print('Request failed!');
              //         return;
              //       }
              //       print('Done!');
              //       setState(() {
              //         access = true;
              //       });
              //     },
              //     child: Text('Press to access camera')),

              if (access)
                Container(
                    width: widget.video.videoWidth.toDouble(),
                    height: widget.video.videoHeight.toDouble(),
                    child: HtmlElementView(viewType: 'video-view')),
              // if (photoBytes != null) Image.memory(photoBytes!),
            ],
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          if (access) {
            takePic(context);
          } else {
            requestCamera();
          }
        },
        child: Icon(
          Icons.camera,
        ),
      ),
    );
  }
}

/* camera.dart */
