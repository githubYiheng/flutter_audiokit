import Flutter

public class FlutterAudioKitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        // Set up Pigeon Host API
        let bridge = AudioKitBridge()
        AudioKitHostApiSetup.setUp(binaryMessenger: messenger, api: bridge)

        // Set up Flutter API for callbacks
        let flutterApi = AudioKitFlutterApi(binaryMessenger: messenger)
        bridge.flutterApi = flutterApi
    }
}
