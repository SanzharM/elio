class Entity {
  final String? email;
  final String? secret;
  final String? name;

  Entity({required this.email, required this.secret, required this.name});

  static Entity fromQR(String barcode) {
    final List<String> pathSegments = Uri.tryParse(barcode)?.pathSegments ?? [];
    return Entity(
      email: pathSegments.isEmpty ? null : pathSegments.first.split(':').last,
      secret: Uri.tryParse(barcode)?.queryParameters['secret'],
      name: Uri.tryParse(barcode)?.queryParameters['issuer'],
    );
  }
}
