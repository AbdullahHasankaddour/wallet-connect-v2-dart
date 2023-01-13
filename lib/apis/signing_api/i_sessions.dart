import 'package:wallet_connect_v2_dart/apis/core/store/i_store_user.dart';
import 'package:wallet_connect_v2_dart/apis/signing_api/models/session_models.dart';

abstract class ISessions extends IStoreUser {
  Future<void> init();
  bool has(String topic);
  Future<void> set(String topic, SessionData value);
  Future<void> update(
    String topic, {
    int? expiry,
    Map<String, Namespace>? namespaces,
  });
  SessionData? get(String topic);
  List<SessionData> getAll();
  Future<void> delete(String topic);
}
