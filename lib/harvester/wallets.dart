import 'package:farmr_client/blockchain.dart';
import 'package:farmr_client/wallets/coldWallets/chiaexplorer.dart';
import 'package:farmr_client/wallets/coldWallets/coldwallet.dart';
import 'package:farmr_client/wallets/coldWallets/flaxexplorer.dart';
import 'package:farmr_client/wallets/coldWallets/posatio.dart';
import 'package:farmr_client/wallets/localWallets/localWallet.dart';
import 'package:farmr_client/wallets/poolWallets/flexPoolWallet.dart';
import 'package:farmr_client/wallets/poolWallets/foxyPoolWallet.dart';
import 'package:farmr_client/wallets/poolWallets/genericPoolWallet.dart';
import 'package:farmr_client/wallets/wallet.dart';

class HarvesterWallets {
  //list of wallets
  List<Wallet> wallets = [];
  //sums all wallets into one, useful for getting latest block farmed and how many days ago -> effort
  Wallet get walletAggregate => wallets.reduce((w1, w2) => w1 + w2);

  //list of local wallets
  List<Wallet> get localWallets =>
      wallets.where((wallet) => wallet.type == WalletType.Local).toList();
  //sums all local wallets into one
  LocalWallet get localWalletAggregate =>
      localWallets.reduce((w1, w2) => (w1 + w2)) as LocalWallet;

  //list of cold wallets
  List<Wallet> get coldWallets =>
      wallets.where((wallet) => wallet.type == WalletType.Cold).toList();
  //sums all cold wallets into one
  ColdWallet get coldWalletAggregate =>
      coldWallets.reduce((w1, w2) => w1 + w2) as ColdWallet;

  //list of pool wallets
  List<Wallet> get poolWallets =>
      wallets.where((wallet) => wallet.type == WalletType.Pool).toList();
  //sums all pool wallets into one
  GenericPoolWallet get poolWalletAggregate =>
      poolWallets.reduce((w1, w2) => w1 + w2) as GenericPoolWallet;

  Future<void> getWallets(Blockchain blockchain) async {
    for (String address in blockchain.config.coldWalletAddresses) {
      if (address.startsWith("xch"))
        wallets
            .add(ChiaExplorerWallet(blockchain: blockchain, address: address));
      else if (address.startsWith("xfx"))
        wallets
            .add(FlaxExplorerWallet(blockchain: blockchain, address: address));
      else
        wallets.add(PosatIOWallet(blockchain: blockchain, address: address));
    }

    for (String address in blockchain.config.flexpoolAddresses)
      wallets.add(FlexpoolWallet(blockchain: blockchain, address: address));

    for (String publicKey in blockchain.config.foxyPoolPublicKeys)
      wallets.add(FoxyPoolWallet(blockchain: blockchain, publicKey: publicKey));

    //initializes all wallets
    for (Wallet wallet in wallets) await wallet.init();
  }
}
