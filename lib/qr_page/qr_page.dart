import 'package:elio/constants/app_colors.dart';
import 'package:elio/constants/app_constraints.dart';
import 'package:elio/main_page/main_page.dart';
import 'package:elio/models/entity.dart';
import 'package:elio/qr_page/info_page.dart';
import 'package:elio/utils/application.dart';
import 'package:elio/utils/otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanner extends StatefulWidget {
  final bool isAuthorized;
  const QrCodeScanner({Key? key, this.isAuthorized = false}) : super(key: key);

  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;

  bool isFlashOn = false;
  bool isLoading = false;

  void _onQRViewCreated(QRViewController qrViewController) {
    _qrController = qrViewController;
    bool _isLoading = false;
    _qrController?.scannedDataStream.listen((event) async {
      if (_isLoading) return;
      if (event.code == null || event.code!.isEmpty) return;
      setState(() => _isLoading = true);

      final _entity = Entity.fromQR(event.code!);
      if (_entity.secret == null) return;
      await Application.addBarcode(event.code!);
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) => MainPage()));
      setState(() => _isLoading = false);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  void stopCamera() async => await _qrController?.stopCamera();
  void resumeCamera() async {
    await _qrController?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.question_circle),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => InfoPage()),
            ),
          ),
        ],
      ),
      body: _qrController?.hasPermissions ?? true
          ? SafeArea(
              child: Stack(
                children: [
                  QRView(key: _qrKey, onQRViewCreated: _onQRViewCreated),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                        border: Border.all(width: 2.0, color: AppColors.yellow),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstraints.padding),
                      child: IconButton(
                        color: AppColors.grey.withOpacity(0.5),
                        padding: EdgeInsets.zero,
                        icon: isFlashOn ? const Icon(Icons.flashlight_on, size: 32) : const Icon(Icons.flashlight_off, size: 32),
                        onPressed: () async {
                          isFlashOn = await _qrController?.getFlashStatus() ?? false;
                          await _qrController?.toggleFlash();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  if (isLoading) const Center(child: CircularProgressIndicator.adaptive()),
                ],
              ),
            )
          : Center(
              child: GestureDetector(
                onTap: () async => await openAppSettings(),
                child: const Padding(
                  padding: EdgeInsets.all(AppConstraints.padding),
                  child: Text(
                    'Предоставьте доступ к камере в настройках, чтобы сканировать QR-коды.\nНажмите, чтобы перейти в Настройки',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
    );
  }
}
