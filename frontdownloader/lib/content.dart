import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Content {
  String title;
  Image thumbnail;
  String url;

  Content({required this.title, required this.thumbnail, required this.url});

  @override
  String toString() {
    return ("$title $thumbnail");
  }
}