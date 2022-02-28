import 'package:elio/constants/app_colors.dart';
import 'package:elio/utils/application.dart';
import 'package:elio/main_page/main_page.dart';
import 'package:elio/qr_page/qr_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StatefulWidget widget = QrCodeScanner(isAuthorized: false);

  try {
    final _barcodes = await Application.getBarcodes().timeout(const Duration(seconds: 2));
    if (_barcodes != null && _barcodes.isNotEmpty) widget = MainPage();
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
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: AppColors.grey,
          iconTheme: IconThemeData(color: AppColors.red),
          actionsIconTheme: IconThemeData(color: AppColors.red),
        ),
        iconTheme: IconThemeData(color: AppColors.red),
        cupertinoOverrideTheme: CupertinoThemeData(primaryColor: AppColors.white),
        scaffoldBackgroundColor: AppColors.grey,
        brightness: Brightness.light,
      ),
    );
  }
}
