import 'package:elio/utils/application.dart';
import 'package:elio/main_page/main_page.dart';
import 'package:elio/qr_page/qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  StatefulWidget widget = QrCodeScanner(isAuthorized: false);

  try {
    final _token = await Application.getTokens().timeout(const Duration(seconds: 2));
    if (_token != null && _token.length >= 20) widget = MainPage();
  } catch (e) {
    print(e);
  }

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(App(widget));
}

class App extends StatelessWidget {
  final Widget widget;
  const App(this.widget);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elio',
      home: widget,
      debugShowCheckedModeBanner: false,
    );
  }
}
