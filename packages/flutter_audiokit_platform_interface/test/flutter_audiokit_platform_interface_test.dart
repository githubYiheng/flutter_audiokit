import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_audiokit_platform_interface/flutter_audiokit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAudioKitPlatform extends FlutterAudioKitPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String> createEngine() async => 'mock-engine-id';

  @override
  Future<String> createAudioPlayer() async => 'mock-player-id';
}

void main() {
  group('FlutterAudioKitPlatform', () {
    test('default instance throws StateError', () {
      expect(
        () => FlutterAudioKitPlatform.instance,
        throwsA(isA<StateError>()),
      );
    });

    test('can set mock instance', () {
      final mock = MockFlutterAudioKitPlatform();
      FlutterAudioKitPlatform.instance = mock;
      expect(FlutterAudioKitPlatform.instance, mock);
    });

    test('createEngine returns mock value', () async {
      final mock = MockFlutterAudioKitPlatform();
      FlutterAudioKitPlatform.instance = mock;
      expect(
          await FlutterAudioKitPlatform.instance.createEngine(),
          'mock-engine-id');
    });
  });
}
