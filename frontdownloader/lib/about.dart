import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontdownloader/main.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
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
            "About",
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
        body: Center(
            child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text("YT-Manifest",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Image.asset('assets/icons8-youtube-250.png'),
            const SizedBox(
              height: 10,
            ),
            const Text(
                "An application for downloading youtube videos and",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
                "saving youtube links.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
                "Platforms: android, ios, windows and linux.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 30,
            ),
            const Text(
                "Contact:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
                "Designed and developed by Sthembiso Vinjwa",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
                "Gmail: vinjwacr7@gmail.com",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )));
  }
}
