import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Content {
  String title;
  Image thumbnail;

  Content({required this.title, required this.thumbnail});

  @override
  String toString() {
    return ("$title $thumbnail");
  }
}