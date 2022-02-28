import 'dart:math';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  int _index = 0;
  static const List<String> _gifs = [
    'https://64.media.tumblr.com/f62164b4b0c4eb218811911397382d4f/tumblr_p9afc4gIWF1uq251zo1_540.gifv',
  ];

  @override
  void initState() {
    super.initState();
    _index = Random.secure().nextInt(_gifs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                _gifs[_index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text('Unable to load media:\n$error\n'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
