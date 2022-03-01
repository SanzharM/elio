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
    'https://64.media.tumblr.com/2655cee43d6ea4fa9d946afa31f4dc16/tumblr_inline_p6xtzw3LlW1qk48gt_540.gifv',
    'https://78.media.tumblr.com/c377bddb06d689af5c68a8c9fd2e3b36/tumblr_p5f9ny7PXV1uws463o1_400.gif',
    'https://78.media.tumblr.com/b20afdacff3401e33194a5b95c7b0191/tumblr_inline_p7t00yhYtN1sismob_540.gif',
    'https://64.media.tumblr.com/3645b5692124bc78faa8692280848c15/tumblr_p3fgcnUsjf1wdrr4jo1_540.gifv',
    'https://d2rdhxfof4qmbb.cloudfront.net/wp-content/uploads/20181123191258/Call-Me-By-Your-Name.gif',
    'https://64.media.tumblr.com/312f5cbee01fd3a77a18c794e39b6cc2/tumblr_p2ai30LxLq1wmy13to2_540.gifv',
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
        child: Center(
          child: Image.network(
            _gifs[_index],
            // fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: CircularProgressIndicator.adaptive(),
            ),
            errorBuilder: (context, error, stackTrace) => Text('Unable to load media:\n$error\n'),
          ),
        ),
      ),
    );
  }
}
