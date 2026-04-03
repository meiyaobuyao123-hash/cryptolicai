import 'package:url_launcher/url_launcher.dart';

class CefiDeeplinkService {
  static const _deepLinks = {
    'binance': ('bnc://app.binance.com/en/earn', 'https://www.binance.com/en/earn'),
    'okx': ('okx://earn', 'https://www.okx.com/earn'),
    'bybit': ('bybit://earn', 'https://www.bybit.com/en/earn'),
    'coinbase': ('coinbase://earn', 'https://www.coinbase.com/earn'),
    'gate-io': ('gateio://earn', 'https://www.gate.io/simple-earn'),
    'crypto-com': ('crypto.com://earn', 'https://crypto.com/earn'),
    'kucoin': ('kucoin://earn', 'https://www.kucoin.com/earn'),
  };

  static Future<void> openExchange(String exchangeName) async {
    if (!isSupported(exchangeName)) return;
    final key = exchangeName.toLowerCase().replaceAll('.', '-').replaceAll(' ', '-');
    final links = _deepLinks[key];

    if (links != null) {
      final deepLink = Uri.parse(links.$1);
      final webUrl = Uri.parse(links.$2);

      if (await canLaunchUrl(deepLink)) {
        await launchUrl(deepLink, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  static bool isSupported(String exchangeName) {
    final key = exchangeName.toLowerCase().replaceAll('.', '-').replaceAll(' ', '-');
    return _deepLinks.containsKey(key);
  }
}
