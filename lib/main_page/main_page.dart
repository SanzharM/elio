import 'dart:async';

import 'package:elio/constants/app_colors.dart';
import 'package:elio/constants/app_constraints.dart';
import 'package:elio/models/entity.dart';
import 'package:elio/qr_page/qr_page.dart';
import 'package:elio/utils/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Entity> entities = [];

  Future<void> _getEntities() async {
    List<String> barcodes = await Application.getBarcodes() ?? [];
    if (barcodes.isEmpty) {
      setState(() => entities = []);
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (context) => QrCodeScanner(),
      ));
      return;
    }
    entities = [];
    barcodes.forEach((e) {
      entities.add(Entity.fromQR(e));
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Icon(CupertinoIcons.add),
        onPressed: () async {
          bool? response = await Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => QrCodeScanner(isAuthorized: true),
          ));
          if (response == true) _getEntities();
        },
      ),
      body: SafeArea(
        child: CupertinoScrollbar(
          child: ListView.builder(
            padding: EdgeInsets.all(AppConstraints.padding),
            physics: const BouncingScrollPhysics(),
            itemCount: entities.length,
            itemBuilder: (context, i) => EntityCard(entity: entities[i], onUpdate: _getEntities),
          ),
        ),
      ),
    );
  }
}

class EntityCard extends StatefulWidget {
  final Entity entity;
  final void Function() onUpdate;

  const EntityCard({
    Key? key,
    required this.entity,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EntityCardState createState() => _EntityCardState();
}

class _EntityCardState extends State<EntityCard> with TickerProviderStateMixin {
  late Timer timer;
  String _code = '';

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _code = '${widget.entity.getTOTP()}');
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int second = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch).second;
    if (second > 30) second -= 30;
    double loaderValue = second * 100 / 30;
    return CupertinoButton(
      padding: EdgeInsets.all(AppConstraints.padding),
      onPressed: showModal,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 124),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(AppConstraints.padding),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(width: 0.1, color: AppColors.blue),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('${widget.entity.name}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Padding(padding: EdgeInsets.only(top: 4.0)),
                      Text('${widget.entity.email}', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                CircularProgressIndicator(value: loaderValue / 100),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 16.0)),
            Expanded(
              child: Center(
                child: Text(
                  '$_code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: 2.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) => Container(
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(AppConstraints.padding),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text('Скопировать', textAlign: TextAlign.center),
                ),
                onPressed: () {
                  _tryCopyToClipboard();
                  Navigator.of(context).pop();
                  _showSnackbar(context, 'Код скопирован', isSuccess: true);
                },
              ),
            ),
            Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text('Удалить', textAlign: TextAlign.center),
                ),
                onPressed: () async {
                  if (widget.entity.barcode != null) {
                    bool isSuccess = await Application.deleteBarcode(widget.entity.barcode!);
                    widget.onUpdate();
                    if (isSuccess) {
                      Navigator.of(context).pop();
                      _showSnackbar(context, '${widget.entity.name} удален');
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tryCopyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: '${widget.entity.getTOTP()}'));
      const snackBar = SnackBar(
        content: Padding(
          padding: EdgeInsets.all(AppConstraints.padding / 2),
          child: Text('Код скопирован'),
        ),
        duration: const Duration(milliseconds: 1200),
        backgroundColor: AppColors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print('During copying to Clipboard, Error Occured: $e');
    }
  }

  void _showSnackbar(BuildContext context, String text, {bool isSuccess = false}) {
    final snackBar = SnackBar(
      content: Padding(
        padding: const EdgeInsets.all(AppConstraints.padding / 2),
        child: Text(text),
      ),
      duration: const Duration(milliseconds: 1200),
      backgroundColor: isSuccess ? AppColors.green : AppColors.black.withOpacity(0.65),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
