import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet_connect_v2_dart/apis/core/core.dart';
import 'package:wallet_connect_v2_dart/apis/core/i_core.dart';
import 'package:wallet_connect_v2_dart/apis/core/pairing/utils/pairing_models.dart';
import 'package:wallet_connect_v2_dart/apis/core/relay_client/relay_client.dart';
import 'package:wallet_connect_v2_dart/apis/core/relay_client/relay_client_models.dart';
import 'package:wallet_connect_v2_dart/apis/models/basic_errors.dart';

import '../shared/shared_test_values.dart';
import 'shared/shared_test_utils.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const TEST_PUB_KEY =
      '9088c381b2022c6311d9b4738e221029ff4b8f3c13860a795c960eac043e7d28';
  const TEST_PRIV_KEY =
      'f24230adbb096e81f4a2a06450c206cafaf49dc6a60daf25d09e05c011e47ed2';
  const TEST_TOPIC = 'abc123';
  const TEST_MESSAGE = 'swagmasterss';

  group('Relay throws errors', () {
    test('when connection parameters are invalid', () async {
      final ICore core = Core(
        projectId: 'abc',
        memoryStore: true,
      );

      expect(
        () async => await core.start(),
        throwsA(isA<Error>()),
      );
    });
  });

  group('Relay Client', () {
    ICore core = Core(
      projectId: TEST_PROJECT_ID,
      memoryStore: true,
    );
    late RelayClient relayClient;
    MockMessageTracker messageTracker = MockMessageTracker();
    MockTopicMap topicMap = MockTopicMap();

    setUp(() async {
      when(topicMap.has(TEST_TOPIC)).thenReturn(true);

      await core.start();
      relayClient = RelayClient(
        core,
        messageTracker: messageTracker,
        topicMap: topicMap,
      );
      await relayClient.init();
    });

    // tearDown(() async {
    //   await relayClient.disconnect();
    // });

    test('Handle publish broadcasts and stores the message event', () async {
      int counter = 0;
      relayClient.onRelayClientMessage.subscribe((MessageEvent? args) {
        counter++;
      });

      when(messageTracker.messageIsRecorded(
        TEST_TOPIC,
        TEST_MESSAGE,
      )).thenAnswer(
        (_) => false,
      );

      bool published = await relayClient.handlePublish(
        TEST_TOPIC,
        TEST_MESSAGE,
      );
      expect(published, true);
      expect(counter, 1);

      verify(
        messageTracker.recordMessageEvent(
          TEST_TOPIC,
          TEST_MESSAGE,
        ),
      ).called(1);
    });

    group('JSON RPC', () {
      late ICore coreA;
      late ICore coreB;

      setUp(() async {
        coreA = Core(
          relayUrl: TEST_RELAY_URL,
          projectId: TEST_PROJECT_ID,
          memoryStore: true,
        );
        coreB = Core(
          relayUrl: TEST_RELAY_URL,
          projectId: TEST_PROJECT_ID,
          memoryStore: true,
        );
        await coreA.start();
        await coreB.start();
        coreA.relayClient = RelayClient(coreA);
        coreB.relayClient = RelayClient(coreB);
        await coreA.relayClient.init();
        await coreB.relayClient.init();
      });

      tearDown(() async {
        await coreA.relayClient.disconnect();
        await coreB.relayClient.disconnect();
      });

      test('Publish is received by clients', () async {
        CreateResponse response = await coreA.pairing.create();
        await coreB.pairing.pair(uri: response.uri, activatePairing: true);
        coreA.pairing.activate(topic: response.topic);

        int counterA = 0;
        int counterB = 0;
        coreA.relayClient.onRelayClientMessage.subscribe((args) {
          expect(args == null, false);
          expect(args!.topic, response.topic);
          expect(args.message, TEST_MESSAGE);
          counterA++;
        });
        coreB.relayClient.onRelayClientMessage.subscribe((args) {
          expect(args == null, false);
          expect(args!.topic, response.topic);
          expect(args.message, TEST_MESSAGE);
          counterB++;
        });

        // await coreA.relayClient.unsubscribe(response.topic);
        // await coreB.relayClient.unsubscribe(response.topic);

        await coreA.relayClient.publish(
          topic: response.topic,
          message: TEST_MESSAGE,
          ttl: 6000,
          tag: 0,
        );
        await coreB.relayClient.publish(
          topic: response.topic,
          message: 'Swag',
          ttl: 6000,
          tag: 0,
        );

        await Future.delayed(Duration(milliseconds: 100));

        expect(counterA, 1);
        expect(counterB, 1);
      });
    });
  });
}
