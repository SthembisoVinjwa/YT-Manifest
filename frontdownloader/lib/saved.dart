import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

const urlPrefix = 'http://localhost:5000';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => SavedScreenState();
}

class SavedScreenState extends State<SavedScreen> {
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
                onPressed: () {},
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
      backgroundColor: Colors.white,
      body: _mainPage(),
    );
  }

  Widget _mainPage() {
    final List<String> entries = <String>['A', 'B', 'C', 'rr', 'we', 'et'];
    final List<int> colorCodes = <int>[600, 500, 100, 30, 40, 40];

    final GlobalKey<AnimatedListState> _key = GlobalKey();

    void _removeItem(int index) {
      String removed;
      if (entries[0].isNotEmpty) {
        removed = entries.removeAt(index);
      } else {
        removed = entries.removeAt(index);
      }
      _key.currentState!.removeItem(index, (_, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: Card(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            elevation: 0,
            child: ListTile(
              shape: const BorderDirectional(
                bottom: BorderSide(color: Colors.white, width: 3),
              ),
              contentPadding: EdgeInsets.all(30),
              title: Text(removed, style: TextStyle(fontSize: 18)),
            ),
          ),
        );
      }, duration: const Duration(seconds: 1));
    }

    return AnimatedList(
      key: _key,
      initialItemCount: entries.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index, animation) {
        return SizeTransition(
            key: UniqueKey(),
            sizeFactor: animation,
            child: Container(
              height: 135,
              child: Card(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                elevation: 0,
                child: ListTile(
                  shape: const BorderDirectional(
                    bottom: BorderSide(color: Colors.white, width: 3),
                  ),
                  contentPadding: const EdgeInsets.all(30),
                  title: Text(entries[index],
                      style: const TextStyle(fontSize: 18)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                          onPressed: () => {},
                          icon: const Icon(Icons.download_for_offline_rounded),
                          label: const Text('Download')),
                      IconButton(
                        icon: const Icon(color: Colors.redAccent, Icons.delete),
                        onPressed: () => _removeItem(index),
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
