import 'package:event/event.dart';
import 'package:wallet_connect_v2_dart/apis/signing_api/models/proposal_models.dart';
import 'package:wallet_connect_v2_dart/apis/signing_api/models/session_models.dart';

class SessionProposal extends EventArgs {
  int id;
  ProposalData params;

  SessionProposal(
    this.id,
    this.params,
  );
}

class SessionConnect extends EventArgs {
  SessionData session;

  SessionConnect(
    this.session,
  );
}

class SessionUpdate extends EventArgs {
  int id;
  String topic;
  Map<String, Namespace> namespaces;

  SessionUpdate(
    this.id,
    this.topic,
    this.namespaces,
  );
}

class SessionExtend extends EventArgs {
  int id;
  String topic;

  SessionExtend(this.id, this.topic);
}

class SessionPing extends EventArgs {
  int id;
  String topic;

  SessionPing(this.id, this.topic);
}

class SessionDelete extends EventArgs {
  int id;
  String topic;

  SessionDelete(this.id, this.topic);
}

class SessionExpire extends EventArgs {
  final String topic;

  SessionExpire(this.topic);
}

class SessionRequest extends EventArgs {
  int id;
  String topic;
  String method;
  String chainId;
  dynamic params;

  SessionRequest(
    this.id,
    this.topic,
    this.method,
    this.chainId,
    this.params,
  );
}

class SessionEvent extends EventArgs {
  int id;
  String topic;
  String name;
  String chainId;
  dynamic data;

  SessionEvent(
    this.id,
    this.topic,
    this.name,
    this.chainId,
    this.data,
  );
}

class ProposalExpire extends EventArgs {
  final int id;

  ProposalExpire(this.id);
}
