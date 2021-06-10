import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:record_test/recorder_init.dart';
import 'audio_player.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool showPlayer = false;
  String path;
  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Card(
            // color: Colors.green,
            child: Container(
              height: 80,
              // padding: EdgeInsets.all(5),
              // margin: EdgeInsets.all(0),
              child: FutureBuilder<String>(
                future: getPath(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (showPlayer) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: AudioPlayer(
                          path: snapshot.data,
                          onDelete: () {
                            setState(() => showPlayer = false);
                          },
                          onSend: (){
                            setState(() {
                              print('sent');
                              showPlayer = false;
                            });
                          },
                        ),
                      );
                    } else {
                      return AudioRecorder(
                        path: snapshot.data,
                        onStop: () {
                          setState(() => showPlayer = true);
                        },
                      );
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<String> getPath() async {
    if (path == null) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.m4a';
    }
    print(path.toString());
    return path;
  }
  uploadFile(String filePath) async {
    var postUri = Uri.parse("apiUrl");
    http.MultipartRequest request = new http.MultipartRequest("POST", postUri);
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
        'file', filePath);
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    print(response.statusCode);
  }
}