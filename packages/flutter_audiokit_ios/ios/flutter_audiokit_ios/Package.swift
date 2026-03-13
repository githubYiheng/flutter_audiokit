// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_audiokit_ios",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "flutter-audiokit-ios", targets: ["flutter_audiokit_ios"])
    ],
    dependencies: [
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/SoundpipeAudioKit.git", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "flutter_audiokit_ios",
            dependencies: [
                .product(name: "AudioKit", package: "AudioKit"),
                .product(name: "AudioKitEX", package: "AudioKitEX"),
                .product(name: "SoundpipeAudioKit", package: "SoundpipeAudioKit"),
            ],
            resources: []
        )
    ]
)
