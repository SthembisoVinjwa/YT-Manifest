import 'package:flutter/material.dart';
import 'package:frontdownloader/saved.dart';
import 'package:frontdownloader/support.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'about.dart';
import 'ad_service.dart';
import 'bottom_banner_ad.dart';
import 'download.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

const urlPrefix = 'http://localhost:5000';

Future<void> main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();

    final adService = AdService(MobileAds.instance);
    GetIt.instance.registerSingleton<AdService>(adService);

    await adService.init();

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: const Color.fromRGBO(59, 59, 152, .1),
      100: const Color.fromRGBO(59, 59, 152, .2),
      200: const Color.fromRGBO(59, 59, 152, .3),
      300: const Color.fromRGBO(59, 59, 152, .4),
      400: const Color.fromRGBO(59, 59, 152, .5),
      500: const Color.fromRGBO(59, 59, 152, .6),
      600: const Color.fromRGBO(59, 59, 152, .7),
      700: const Color.fromRGBO(59, 59, 152, .8),
      800: const Color.fromRGBO(59, 59, 152, .9),
      900: const Color.fromRGBO(59, 59, 152, 1),
    };

    //0xffff0202 = red

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xff3b3b98, color),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final TextEditingController linkController = TextEditingController();
  GlobalKey key = GlobalKey();
  String login = 'log In';
  String message = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff3b3b98),
              ),
              child: Text(
                'YT-Manifest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
            ),
            ListTile(
              title: const Text('Saved Links'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SavedScreen()));
              },
            ),
            ListTile(
              title: const Text('Support Developer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SupportScreen()));
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutScreen()));
              },
            )
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          elevation: 0,
          title: const Text(
            "YT-Manifest",
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
                            builder: (context) => const SavedScreen()));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Icon(Icons.playlist_add_check_circle),
                      SizedBox(
                        width: 10,
                      ), // icon
                      Text('Saved Links'), // text
                    ],
                  ),
                ))
          ],
        ),
      ),
      body: _mainPage(context),
      bottomNavigationBar: const BottomBannerAd(),
    );
  }

  Widget _mainPage(context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // youtubeLogo(),
                Lottie.asset('assets/lf30_editor_etx2bchi.json',
                    height: 150, width: 150),
                const SizedBox(
                  height: 25,
                ),
                HeartbeatProgressIndicator(
                  child: const Text(
                    "Paste/Insert link:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: linkContainerField('Youtube link', linkController),
                ),
                const SizedBox(
                  height: 45,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    savebutton(context),
                    const SizedBox(width: 25),
                    downloadbutton(context),
                  ],
                ),
                const SizedBox(height: 40),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
              ]),
        ));
  }

  Widget savebutton(context) {
    return Material(
        elevation: 5,
        color: Colors.green,
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
          minWidth: MediaQuery
              .of(context)
              .size
              .width * 1 / 10,
          height: 55,
          child: Stack(
            children: const [
              Text('Save Link',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          onPressed: () async {
            var yt = YoutubeExplode();

            showDialog(
                context: context,
                builder: (context) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(
                            0,
                            ((key.currentContext?.findRenderObject()
                            as RenderBox)
                                .localToGlobal(Offset.zero))
                                .dy +
                                75,
                            0,
                            0),
                        child: Column(
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
                        )),
                  );
                });

            try {
              var video = await yt.videos.get(linkController.text.trim());

              if (video.isLive) {
                throw Exception();
              }

              var manifest = await yt.videos.streamsClient.getManifest(
                  video.url);

              //save link
              if (Platform.isLinux) {
                var path = await getApplicationDocumentsDirectory();
                var filename = '${path?.path}/YT-Manifest-links.txt';
                var file = File(filename);
                if (file.existsSync()) {
                  file.readAsString().then((value) {
                    if (value.contains(video.url)) {
                      setState(() {
                        message = 'Link already saved!';
                      });
                      Timer timer = Timer(const Duration(seconds: 2), () {
                        setState(() {
                          message = '';
                        });
                      });
                    } else {
                      file.writeAsString('${video.url}\n',
                          mode: FileMode.append);
                      setState(() {
                        message = 'Link saved!';
                      });
                      Timer timer = Timer(const Duration(seconds: 2), () {
                        setState(() {
                          message = '';
                        });
                      });
                    }
                  });
                } else {
                  file.writeAsString('${video.url}\n', mode: FileMode.append);
                  setState(() {
                    message = 'Link saved!';
                  });
                  Timer timer = Timer(const Duration(seconds: 2), () {
                    setState(() {
                      message = '';
                    });
                  });
                }
              } else {
                var permissionStatus = await Permission.storage.request();
                if (permissionStatus.isGranted) {
                  var path = await getApplicationDocumentsDirectory();
                  var filename = '${path?.path}/links.txt';
                  var file = File(filename);
                  if (file.existsSync()) {
                    file.readAsString().then((value) {
                      if (value.contains(video.url)) {
                        setState(() {
                          message = 'Link already saved!';
                        });
                        Timer timer = Timer(const Duration(seconds: 2), () {
                          setState(() {
                            message = '';
                          });
                        });
                      } else {
                        file.writeAsString('${video.url}\n',
                            mode: FileMode.append);
                        setState(() {
                          message = 'Link saved!';
                        });
                        Timer timer = Timer(const Duration(seconds: 2), () {
                          setState(() {
                            message = '';
                          });
                        });
                      }
                    });
                  } else {
                    file.writeAsString('${video.url}\n', mode: FileMode.append);
                    setState(() {
                      message = 'Link saved!';
                    });
                    Timer timer = Timer(const Duration(seconds: 2), () {
                      setState(() {
                        message = '';
                      });
                    });
                  }
                }
              }
              Navigator.pop(context);
            } catch (error) {
              showErrorMessage(
                  'Invalid Youtube ID or URL: "${linkController.text.trim()}"\n'
                      'Ensure you have stable internet connection and insert a valid youtube video link');
            }
          },
        ));
  }

  Widget downloadbutton(context) {
    return Material(
        elevation: 5,
        color: const Color(0xff3b3b98),
        borderRadius: BorderRadius.circular(15.0),
        child: MaterialButton(
          minWidth: MediaQuery
              .of(context)
              .size
              .width * 1 / 10,
          height: 55,
          child: Stack(
            key: key,
            children: const [
              Text('Download',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          onPressed: () async {
            var yt = YoutubeExplode();

            showDialog(
                context: context,
                builder: (context) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(
                            0,
                            ((key.currentContext?.findRenderObject()
                            as RenderBox)
                                .localToGlobal(Offset.zero))
                                .dy +
                                75,
                            0,
                            0),
                        child: Column(
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
                        )),
                  );
                });

            try {
              var video = await yt.videos.get(linkController.text.trim());

              if (video.isLive) {
                throw Exception();
              }

              var manifest =
              await yt.videos.streamsClient.getManifest(video.url);
              Image thumbnail = Image.network(video.thumbnails.standardResUrl);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DownloadScreen(
                          video: video,
                          manifest: manifest,
                          thumbnail: thumbnail,
                        )),
              );
            } catch (error) {
              showErrorMessage(
                  'Invalid Youtube ID or URL: "${linkController.text.trim()}"\n'
                      'Ensure you have stable internet connection and insert a valid youtube video link');
            }
          },
        ));
  }

  Widget youtubeLogo() {
    return Image.asset(
      "assets/icons8-youtube-250.png",
      height: 150,
      width: 150,
    );
  }

  void showErrorMessage(String message) {
    AlertDialog inputFail = AlertDialog(
      title: const Text("A Problem Occured"),
      content: Text(message),
      actions: [
        failbutton(context),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return inputFail;
      },
    );
  }

  Widget failbutton(context) {
    return TextButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: const Text('Ok',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));
  }

  Widget linkContainerField(String hintText,
      TextEditingController textController) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.grey));
    return TextField(
      style: const TextStyle(color: Colors.black),
      controller: textController,
      decoration: InputDecoration(
        prefixIcon: const IconTheme(
            data: IconThemeData(color: Colors.black),
            child: Icon(Icons.https_outlined)),
        hintText: hintText,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
