import 'package:shared_preferences/shared_preferences.dart';

class Application {
  static const _tokensKey = 'ElioTokensKey';
  static const _barcodesKey = 'ElioBarcodesKey';

  static Future<List<String>?> getBarcodes() async {
    final _prefs = await SharedPreferences.getInstance();
    return _prefs.getStringList(_barcodesKey);
  }

  static Future<void> addBarcode(String barcode) async {
    final _prefs = await SharedPreferences.getInstance();
    final _barcodes = (await getBarcodes() ?? []);
    if (_barcodes.contains(barcode)) return;
    await _prefs.setStringList(_barcodesKey, _barcodes..add(barcode));
  }

  static Future<bool> reset() async {
    final _prefs = await SharedPreferences.getInstance();
    return await _prefs.remove(_barcodesKey);
  }

  static Future<bool> deleteBarcode(String barcode) async {
    final _prefs = await SharedPreferences.getInstance();
    final _barcodes = await getBarcodes() ?? [];
    print('all: $_barcodes');
    if (_barcodes.isEmpty || !_barcodes.contains(barcode)) return false;
    _barcodes.remove(barcode);
    print('removed: $_barcodes');
    return await _prefs.setStringList(_barcodesKey, _barcodes);
  }

  //

  static Future<List<String>?> getTokens() async {
    final _prefs = await SharedPreferences.getInstance();
    return _prefs.getStringList(_tokensKey);
  }

  static Future<bool> hasTokens() async {
    final _prefs = await SharedPreferences.getInstance();
    return _prefs.getStringList(_tokensKey) != null;
  }

  static Future<void> addToken(String token) async {
    final _prefs = await SharedPreferences.getInstance();
    final value = (await getTokens() ?? [])..add(token);
    await _prefs.setStringList(_tokensKey, value);
  }

  static void clearStorage() async => (await SharedPreferences.getInstance()).remove(_tokensKey);

  static Future<void> deleteToken(String token) async {
    final tokens = await getTokens();
    if (tokens == null || tokens.isEmpty) return;
    print('Before: $tokens');
    tokens.remove(token);
    print('After: $tokens');
    (await SharedPreferences.getInstance()).setStringList(_tokensKey, tokens);
  }
}
