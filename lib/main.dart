import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
      'video-view',
          (int viewId) => video);

  runApp(MyApp());
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
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? photoBytes;
  var access = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Web Camera'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () async {
                    print('Request!');
                    final success = await requestCamera();
                    if (!success) {
                      print('Request failed!');
                      return;
                    }
                    print('Done!');
                    setState(() {
                      access = true;
                    });
                  },
                  child: Text('Press to access camera')),
              ElevatedButton(
                  onPressed: () async {
                    if (!access) {
                      return;
                    }
                    final bytes = takePic();
                    setState(() {
                      photoBytes = bytes;
                    });
                  },
                  child: Text('Take still photo')),
              if (access)
                Container(
                    width: video.videoWidth.toDouble(),
                    height: video.videoHeight.toDouble(),
                    child: HtmlElementView(viewType: 'video-view')),
              if (photoBytes != null) Image.memory(photoBytes!),
            ]),
          ),
        ));
  }
}

/* camera.dart */
var initialized = false;

final VideoElement video = VideoElement();
final CanvasElement canvas = CanvasElement();

Future<bool> requestCamera() async {
  if (initialized) {
    print('Already init');
    return true;
  }

  try {
    final mediaStream = await window.navigator.mediaDevices!
        .getUserMedia({'video': true, 'audio': false});
    video.srcObject = mediaStream;
    await video.play();
    initialized = true;
    return true;
  } on DomException catch (e) {
    print('Error: ${e.message}');
  }
  return false;
}

Uint8List takePic() {
  assert(initialized);

  final context = canvas.context2D;

  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;
  context.drawImage(video, 0, 0);

  final data = canvas.toDataUrl('image/png');
  final uri = Uri.parse(data);
  return uri.data!.contentAsBytes();
}