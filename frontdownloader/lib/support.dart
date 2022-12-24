import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontdownloader/main.dart';


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
            "YT-Manifest",
            style: TextStyle(
              fontSize: 25.0,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
                padding: const EdgeInsets.all(12.0),
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
        body: const Center(child: Text('Support Sthembiso Vinjwa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
    );
  }

}