import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontdownloader/main.dart';
import 'package:link_text/link_text.dart';


class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => SupportScreenState();
}

class SupportScreenState extends State<SupportScreen> {

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
            "Support Developer",
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
              children:  [
                const SizedBox(
                  height: 100,
                ),
                const Text("YT-Manifest",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Image.asset('assets/icons8-youtube-250.png'),
                const SizedBox(
                  height: 10,
                ),
                const Text("Support developer:",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const LinkText(
                    "https://www.buymeacoffee.com/vinjwacr7e",
                    linkStyle: TextStyle(color: Color(0xff3b3b98),fontSize: 19, fontWeight: FontWeight.bold)),
              ],
            )),
    );
  }

}