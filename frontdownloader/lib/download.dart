import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
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
            var yt = YoutubeExplode();
            MuxedStreamInfo info = widget.manifest.muxed.firstWhere(
                (element) => element.qualityLabel == _dropdownValue);
            var stream = yt.videos.streamsClient.get(info);
            var permissionStatus = await Permission.storage.request();
            if (permissionStatus.isGranted) {
              final file = File(
                  '${'/storage/emulated/0/Download'}/${widget.video.title} + ${widget.video.id}.mp4');
              var fileStream = file.openWrite();
              await stream.pipe(fileStream);
              await fileStream.flush();
              await fileStream.close();
            } else {
              showDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text("Access to local storage denied"),
                  content: const Text(
                      "Allow the application to access your storage in order to download and save the video."),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop;
                        Navigator.of(context).pop;
                      },
                      child: const Text("Ok"),
                    )
                  ],
                ),
                barrierDismissible: true,
              );
            }
          },
        ));
  }
}
