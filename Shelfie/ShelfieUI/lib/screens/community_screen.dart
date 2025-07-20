import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import 'package:shelfie/config.dart';

class CommunityScreen extends StatefulWidget {
  final String authHeader;

  CommunityScreen({required this.authHeader});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('This is the Community screen'),
      ),
    );
  }
}