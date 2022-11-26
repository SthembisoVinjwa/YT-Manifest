import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'download.dart';

const urlPrefix = 'http://localhost:5000';

void main() {
  runApp(const MyApp());
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

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            elevation: 0,
            leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {}),
            title: const Text("YT-Manifest"),
            centerTitle: true,
            actions: [
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: const BorderSide(color: Color(0xff3b3b98))))),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(Icons.account_circle_outlined),
                        SizedBox(
                          width: 10,
                        ), // icon
                        Text("Log in"), // text
                      ],
                    ),
                  ))
            ],
          ),
        ),
        body: _mainPage(context));
  }

  Widget _mainPage(context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                youtubeLogo(),
                const Text(
                  "Paste/Insert link:",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 45,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: linkContainerField('Youtube link', linkController),
                ),
                const SizedBox(
                  height: 45,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: downloadbutton(context)),
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

            showDialog(
                context: context,
                builder: (context) {
                  return Material(
                    type: MaterialType.transparency,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(
                            0, MediaQuery.of(context).size.height / 2, 0, 0),
                        child: Column(
                          children: const <Widget>[
                            CircularProgressIndicator(
                              color: Color(0xff3b3b98),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        )),
                  );
                });

            var video = await yt.videos.get(linkController.text.trim());
            var manifest = await yt.videos.streamsClient.getManifest(video.url);

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DownloadScreen(
                        video: video,
                        manifest: manifest,
                      )),
            );
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

  Widget linkContainerField(
      String hintText, TextEditingController textController) {
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
