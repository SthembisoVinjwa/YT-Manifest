import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Content {
  String title;
  Image thumbnail;
  String url;
  StreamManifest manifest;
  Video video;

  Content(
      {required this.title,
      required this.thumbnail,
      required this.url,
      required this.manifest,
      required this.video});

  @override
  String toString() {
    return ("$title $thumbnail");
  }
}
