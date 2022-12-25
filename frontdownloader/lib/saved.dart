import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontdownloader/main.dart';

//import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';

//import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'content.dart';
import 'download.dart';

//const urlPrefix = 'http://localhost:5000';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => SavedScreenState();
}

class SavedScreenState extends State<SavedScreen> {
  dynamic getLinks() async {
    List<String> links = [];
    List<Content> videos = [];

    if (Platform.isLinux) {
      var path = await getApplicationDocumentsDirectory();
      var filename = '${path?.path}/YT-Manifest-links.txt';
      var file = File(filename);
      if (file.existsSync()) {
        links = await file.readAsLines();
        for (String link in links) {
          var yt = YoutubeExplode();
          var video = await yt.videos.get(link.trim());
          Image thumbnail = Image.network(video.thumbnails.lowResUrl);
          String title = video.title;
          var manifest = await yt.videos.streamsClient.getManifest(video.url);
          videos.add(Content(
              title: title,
              thumbnail: thumbnail,
              url: video.url,
              manifest: manifest,
              video: video));
        }
        return videos;
      }
    } else {
      var permissionStatus = await Permission.storage.request();
      if (permissionStatus.isGranted) {
        var path = await getApplicationDocumentsDirectory();
        var filename = '${path?.path}/links.txt';
        var file = File(filename);
        if (file.existsSync()) {
          links = await file.readAsLines();
          for (String link in links) {
            var yt = YoutubeExplode();
            var video = await yt.videos.get(link.trim());
            Image thumbnail = Image.network(video.thumbnails.lowResUrl);
            String title = video.title;
            var manifest = await yt.videos.streamsClient.getManifest(video.url);
            videos.add(Content(
                title: title,
                thumbnail: thumbnail,
                url: video.url,
                manifest: manifest,
                video: video));
          }
          return videos;
        }
      }
    }

    return videos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: const Text(
          "Saved Links",
          style: TextStyle(
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.white)))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(Icons.home),
                    SizedBox(
                      width: 10,
                    ), // icon
                    Text('Home'), // text
                  ],
                ),
              ))
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: getLinks(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              return _mainPage(data);
            }
          }
          return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 30,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(59, 59, 152, 20),
                        strokeWidth: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    ScalingText(
                      'Loading...',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _mainPage(List<Content> videos) {
    final GlobalKey<AnimatedListState> key = GlobalKey();

    Future<void> removeItem(int index) async {
      Content removed = videos.removeAt(index);
      if (Platform.isLinux) {
        var path = await getApplicationDocumentsDirectory();
        var filename = '${path?.path}/YT-Manifest-links.txt';
        var file = File(filename);
        if (file.existsSync()) {
          file.writeAsStringSync('', mode: FileMode.write);
          for (Content video in videos) {
            file.writeAsStringSync('${video.url}\n', mode: FileMode.append);
          }
        }
      } else {
        var permissionStatus = await Permission.storage.request();
        if (permissionStatus.isGranted) {
          var path = await getApplicationDocumentsDirectory();
          var filename = '${path?.path}/links.txt';
          var file = File(filename);
          if (file.existsSync()) {
            file.writeAsStringSync('', mode: FileMode.write);
            for (Content video in videos) {
              file.writeAsStringSync('${video.url}\n', mode: FileMode.append);
            }
          }
        }
      }

      key.currentState!.removeItem(index, (_, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            elevation: 0,
            child: ListTile(
              shape: const BorderDirectional(
                bottom: BorderSide(color: Colors.grey, width: 3),
              ),
              contentPadding: const EdgeInsets.all(20),
              title: Row(children: [
                Flexible(child: removed.thumbnail),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Text(
                  removed.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )),
              ]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                      onPressed: () => {},
                      icon: const Icon(Icons.download_for_offline_rounded),
                      label: const Text('Download')),
                  IconButton(
                    icon: const Icon(color: Colors.redAccent, Icons.delete),
                    onPressed: () => removeItem(index),
                  ),
                ],
              ),
            ),
          ),
        );
      }, duration: const Duration(seconds: 1));

      if (videos.isEmpty) {
        Navigator.pop(context);
      }
    }

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No saved links!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return AnimatedList(
      key: key,
      initialItemCount: videos.length,
      padding: const EdgeInsets.all(5),
      itemBuilder: (context, index, animation) {
        return SizeTransition(
            key: UniqueKey(),
            sizeFactor: animation,
            child: SizedBox(
              height: 175,
              child: Card(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                elevation: 0,
                child: ListTile(
                  shape: const BorderDirectional(
                    bottom: BorderSide(color: Colors.grey, width: 3),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  title: Row(children: [
                    Flexible(child: videos[index].thumbnail),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                        child: Text(
                      videos[index].title,
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
                  ]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DownloadScreen(
                                          video: videos[index].video,
                                          manifest: videos[index].manifest,
                                          thumbnail: videos[index].thumbnail,
                                        )));
                          },
                          icon: const Icon(Icons.download_for_offline_rounded),
                          label: const Text('Download')),
                      IconButton(
                        icon: const Icon(color: Colors.redAccent, Icons.delete),
                        onPressed: () => removeItem(index),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
