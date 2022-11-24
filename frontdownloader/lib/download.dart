import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

const urlPrefix = 'http://localhost:5000';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen(
      {super.key, required this.video, required this.manifest});

  final Video video;
  final StreamManifest manifest;

  @override
  State<DownloadScreen> createState() => DownloadScreenState();
}

class DownloadScreenState extends State<DownloadScreen> {
  String? _dropdownValue;
  bool set = false;

  @override
  Widget build(BuildContext context) {
    if (set == false) {
      _dropdownValue = widget.manifest.muxed.last.qualityLabel;
      set = true;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: const Center(child: Text("Youtube video downloader")),
      ),
      backgroundColor: Colors.white,
      body: mainPage(context, _dropdownValue),
    );
  }

  Widget mainPage(context, var data) {
    List<DropdownMenuItem<String>> items = [];

    for (var resolution in widget.manifest.muxed) {
      items.add(DropdownMenuItem(
          value: resolution.qualityLabel,
          child: Text(resolution.qualityLabel)));
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.video.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                thumbnail(widget.video.thumbnails.highResUrl),
                const SizedBox(height: 20),
                DropdownButton(
                  hint: const Text('Resolution'),
                  items: items,
                  iconEnabledColor: const Color(0xff3b3b98),
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  value: _dropdownValue,
                  onChanged: (String? value) {
                    if (value is String) {
                      setState(() {
                        _dropdownValue = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                downloadbutton(context)
              ]),
        ));
  }

  Widget thumbnail(String url) {
    return Image.network(url);
  }

  Widget downloadbutton(context) {
    return Material(
        elevation: 5,
        color: const Color(0xff3b3b98),
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width * 1 / 10,
          height: 55,
          child: Stack(
            children: const [
              Text('Download',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          onPressed: () async {
            getDownloadPath().then((value) async {
              var yt = YoutubeExplode();
              MuxedStreamInfo info = widget.manifest.muxed.firstWhere(
                      (element) => element.qualityLabel == _dropdownValue);
              var stream = yt.videos.streamsClient.get(info);
              var filePath = '${value!}/${widget.video.id}.mp4';
              var file = File(filePath);
              var fileStream = file.openWrite();
              print(fileStream);
              await stream.pipe(fileStream);
              await fileStream.flush();
              await fileStream.close();
            });
          },
        ));
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isLinux) {
        directory = Directory('/Home/Downloads');
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }
}
