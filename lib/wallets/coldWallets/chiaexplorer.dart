import 'dart:convert';

import 'package:farmr_client/blockchain.dart';
import 'package:farmr_client/wallets/coldWallets/coldwallet.dart';
import 'package:farmr_client/wallets/localWallets/localWallet.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

Logger log = Logger("Chia Explorer Cold Wallet");

class ChiaExplorerWallet extends ColdWallet {
  ChiaExplorerWallet(
      {int netBalance = -1,
      int grossBalance = -1,
      required Blockchain blockchain})
      : super(
            netBalance: netBalance,
            grossBalance: grossBalance,
            blockchain: blockchain);

  Future<void> init(String publicAddress, LocalWallet mainWallet) async {
    const String chiaExplorerURL = "https://api2.chiaexplorer.com/";

    try {
      String contents = await http
          .read(Uri.parse(chiaExplorerURL + "balance/" + publicAddress));

      var object = jsonDecode(contents);

      grossBalance = object['grossBalance'] ?? -1;
      netBalance = object['netBalance'] ?? -1;

      String coins = await http.read(
          Uri.parse(chiaExplorerURL + "coinsForAddress/" + publicAddress));

      var coinsObject = jsonDecode(coins);

      for (int i = 0;
          coinsObject['coins'] != null && i < coinsObject['coins'].length;
          i++) {
        var coin = coinsObject['coins'][i];
        if (coin['coinbase'] && int.tryParse(coin['timestamp']) != null)
          mainWallet
              .setDaysAgoWithTimestamp(int.parse(coin['timestamp']) * 1000);
      }
    } catch (error) {
      //404 error means wallet is empty
      if (error is http.ClientException && error.toString().contains("404")) {
        //if wallet is empty then assumes both gross balance and net balance are 0
        grossBalance = 0;
        netBalance = 0;
      } else {
        log.warning("Failed to get info about chia cold wallet");
      }
    }
  }
}
