import 'package:elio/constants/app_colors.dart';
import 'package:elio/constants/app_constraints.dart';
import 'package:elio/models/entity.dart';
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
    if (barcodes.isEmpty) return;
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
      appBar: AppBar(
        centerTitle: true,
        title: Text('ASD'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: entities.length,
          itemBuilder: (context, i) => EntityCard(entity: entities[i]),
        ),
      ),
    );
  }
}

class EntityCard extends StatelessWidget {
  final Entity entity;
  const EntityCard({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _tryCopyToClipboard,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(AppConstraints.padding),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(width: 2.0, color: AppColors.darkRed),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          children: [
            Text('${entity.name}'),
            const Padding(padding: EdgeInsets.only(top: 8.0)),
            Text('${entity.email}'),
            Expanded(
              child: Center(
                child: Text(
                  '${entity.getTOTP()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tryCopyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: entity.secret));
    } catch (e) {
      print('During copying to Clipboard, Error Occured: $e');
    }
  }
}
