import Flutter

public class FlutterAudioKitPlugin: NSObject, FlutterPlugin {
    /// Strong reference to prevent ARC from releasing the bridge.
    private static var bridge: AudioKitBridge?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        // Set up Pigeon Host API
        let b = AudioKitBridge()
        bridge = b
        AudioKitHostApiSetup.setUp(binaryMessenger: messenger, api: b)

        // Set up Flutter API for callbacks
        let flutterApi = AudioKitFlutterApi(binaryMessenger: messenger)
        b.flutterApi = flutterApi
    }
}
