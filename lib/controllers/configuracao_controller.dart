import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracaoController {
  static const String _serverLinkKey = 'server_link';

  Future<String> carregarLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverLinkKey) ?? '';
  }

  Future<void> salvarLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverLinkKey, link.trim());
  }
}
