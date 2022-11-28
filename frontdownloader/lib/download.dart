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
      {super.key,
      required this.video,
      required this.manifest,
      required this.thumbnail});

  final Video video;
  final StreamManifest manifest;
  final Image thumbnail;

  @override
  State<DownloadScreen> createState() => DownloadScreenState();
}

class DownloadScreenState extends State<DownloadScreen> {
  String? _dropdownValue;
  bool set = false;
  var progress;
  double downloadPercentage = 0.0;
  String downloadMessage = '';
  Widget cancel = const Text('');
  bool stop = false;
  bool justDeleted = false;

  @override
  Widget build(BuildContext context) {
    if (set == false) {
      _dropdownValue = widget.manifest.muxed.last.qualityLabel;
      set = true;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }),
        title: const Text(
          "YT-Manifest",
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
        centerTitle: true,
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
          child: Text(
              'Resolution: ${resolution.qualityLabel}  -  Size: ${resolution.size.totalMegaBytes.toStringAsFixed(2)}mb')));
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
                widget.thumbnail,
                const SizedBox(height: 20),
                DropdownButton(
                  hint: const Text('Resolution'),
                  items: items,
                  iconEnabledColor: const Color(0xff3b3b98),
                  style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
                downloadbutton(context),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  width: 60,
                  child: CircularProgressIndicator(
                    color: const Color(0xff3b3b98),
                    valueColor: const AlwaysStoppedAnimation(Color(0xff3b3b98)),
                    value: downloadPercentage/100.0,
                    strokeWidth: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Text(downloadMessage, style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),),
                const SizedBox(height: 30),
                cancel,
              ]),
        ));
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
            String? downloadPath = '';

            var len = info.size.totalBytes;
            var count = 0;

            if (Platform.isLinux) {
              var path = await getDownloadsDirectory();
              downloadPath = path?.path;
              final file = File(
                  '$downloadPath/${widget.video.title} + ${widget.video.id}.mp4');

              // Delete the file if exists.
              if (file.existsSync()) {
                file.deleteSync();
              }

              var fileStream = file.openWrite();

              await for (final data in stream) {
                if (stop == true && justDeleted == false) {
                  break;
                }
                count += data.length;
                setState(() {
                  progress = ((count / len) * 100).ceil();
                  downloadPercentage = (progress == null ? 0.0 : progress*1.0);
                  downloadMessage = 'Download progress: $downloadPercentage%';
                  cancel = cancelDownload(context, "Cancel", file);
                  fileStream.add(data);
                });
              }

              setState(() {
                if (stop == false) {
                  downloadMessage = 'Done!';
                } else {
                  stop = false;
                  if (justDeleted == false) {
                    downloadMessage = 'Download canceled!';
                  } else {
                    downloadMessage = 'Done!';
                  }
                }
                cancel = cancelDownload(context, "Delete", file);
              });

              await fileStream.flush();
              await fileStream.close();
            } else {
              var permissionStatus = await Permission.storage.request();
              if (permissionStatus.isGranted) {
                if (Platform.isAndroid) {
                  downloadPath = '/storage/emulated/0/Download';
                } else {
                  var path = await getDownloadsDirectory();
                  downloadPath = path?.path;
                }
                final file = File(
                    '$downloadPath/${widget.video.title} + ${widget.video.id}.mp4');

                // Delete the file if exists.
                if (file.existsSync()) {
                  file.deleteSync();
                }

                var fileStream = file.openWrite();

                await for (final data in stream) {
                  if (stop == true && justDeleted == false) {
                    break;
                  }
                  count += data.length;
                  setState(() {
                    progress = ((count / len) * 100).ceil();
                    downloadPercentage = (progress == null ? 0.0 : progress*1.0);
                    downloadMessage = 'Download progress: $downloadPercentage%';
                    cancel = cancelDownload(context, "Cancel", file);
                    fileStream.add(data);
                  });
                }

                setState(() {
                  if (stop == false) {
                    downloadMessage = 'Done!';
                  } else {
                    stop = false;
                    if (justDeleted == false) {
                      downloadMessage = 'Download canceled!';
                    } else {
                      downloadMessage = 'Done!';
                    }
                  }
                  cancel = cancelDownload(context, "Delete", file);
                });

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
            }
          },
        ));
  }

  void hide () {
    downloadPercentage = 0.0;
    downloadMessage = '';
    cancel = const Text('');
  }

  Widget cancelDownload(context, String title, File file) {
    return Material(
        elevation: 5,
        color: Colors.red,
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width * 1 / 10,
          height: 55,
          child: Stack(
            children:  [
              Text('   $title   ',
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          onPressed: () async {
            setState(() {
              stop = true;
              justDeleted = false;
              if (title == 'Delete' && file.existsSync()) {
                file.deleteSync();
                hide();
                justDeleted = true;
              }
            });
          },
        ));
  }
}
