import 'package:wallet_connect_v2_dart/apis/signing_api/i_sign_engine.dart';

abstract class ISignClient extends ISignEngine {
  final String protocol = 'wc';
  final int version = 2;

  abstract final ISignEngine engine;
}
