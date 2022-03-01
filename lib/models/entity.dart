import 'package:elio/utils/otp.dart';

class Entity {
  final String? barcode;
  final String? email;
  final String? secret;
  final String? name;

  Entity({
    required this.barcode,
    required this.email,
    required this.secret,
    required this.name,
  });

  static Entity fromQR(String barcode) {
    final List<String> pathSegments = Uri.tryParse(barcode)?.pathSegments ?? [];
    return Entity(
      barcode: barcode,
      email: pathSegments.isEmpty ? null : pathSegments.first.split(':').last,
      secret: Uri.tryParse(barcode)?.queryParameters['secret'],
      name: Uri.tryParse(barcode)?.queryParameters['issuer'],
    );
  }

  int getTOTP() => OTP.generateTOTPCode(
        secret!, // 'DCFQFPZ4GAADHWKUZCRL2DDZNC4PTSAV'
        DateTime.now().millisecondsSinceEpoch,
      );
}
