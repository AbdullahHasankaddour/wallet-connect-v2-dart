import 'package:wallet_connect_v2_dart/apis/core/crypto/crypto.dart';
import 'package:wallet_connect_v2_dart/apis/core/crypto/i_crypto.dart';
import 'package:wallet_connect_v2_dart/apis/core/i_core.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/expirer.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/i_expirer.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/i_json_rpc_history.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/json_rpc_history.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/pairing.dart';
import 'package:wallet_connect_v2_dart/apis/core/relay_client/relay_client.dart';
import 'package:wallet_connect_v2_dart/apis/core/store/i_store.dart';
import 'package:wallet_connect_v2_dart/apis/core/relay_client/i_relay_client.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/i_pairing.dart';
import 'package:wallet_connect_v2_dart/apis/core/store/shared_prefs_store.dart';

class Core implements ICore {
  @override
  String get protocol => 'wc';
  @override
  String get version => '2';

  @override
  final String relayUrl;

  @override
  final projectId;

  @override
  late ICrypto crypto;

  @override
  late IRelayClient relayClient;

  @override
  late IExpirer expirer;

  @override
  late IJsonRpcHistory history;

  @override
  late IPairing pairing;

  @override
  late IStore<Map<String, dynamic>> storage;

  Core({
    this.relayUrl = 'wss://relay.walletconnect.com',
    required this.projectId,
    bool memoryStore = false,
  }) {
    storage = SharedPrefsStores(
      <String, dynamic>{},
      memoryStore: memoryStore,
    );
    crypto = Crypto(this);
    relayClient = RelayClient(this);
    expirer = Expirer(this);
    history = JsonRpcHistory(this);
    pairing = Pairing(this);
  }

  @override
  Future<void> start() async {
    await storage.init();
    await crypto.init();
    await relayClient.init();
    await expirer.init();
    await history.init();
    await pairing.init();
  }
}
