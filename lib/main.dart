import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Panorama Viewer',
      debugShowCheckedModeBanner: false,
      home: CameraPositionPage(),
    );
  }
}

class CameraPositionPage extends StatefulWidget {
  const CameraPositionPage({super.key});

  @override
  CameraPositionPageState createState() => CameraPositionPageState();
}

class CameraPositionPageState extends State<CameraPositionPage> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;

  late File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void escucharSensores() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });
  }

  String getPosition() {
    if (x > 1.5) {
      return 'IZQUIERDA';
    } else if (x < -1.5) {
      return 'DERECHA';
    } else if (y > 1.5) {
      return 'CENTRO';
    } else if (y < -1.5) {
      return 'ARRIBA';
    } else {
      return 'ABAJO';
    }
  }

  IconData getArrow() {
    if (x > 1.5) {
      return Icons.arrow_back_rounded;
    } else if (x < -1.5) {
      return Icons.arrow_forward_rounded;
    } else if (y > 1.5) {
      return Icons.circle_outlined;
    } else if (y < -1.5) {
      return Icons.arrow_upward_rounded;
    } else {
      return Icons.arrow_downward_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    escucharSensores();
    _image = File('1.jpeg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: getImage,
            color: Colors.white,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PanoramaViewer(
            sensorControl: SensorControl.absoluteOrientation,
            child: Image.file(
              _image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            left: 0,
            top: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                Text(
                  getPosition(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 50.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  getArrow(),
                  size: 50.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
