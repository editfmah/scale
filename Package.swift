import PackageDescription

let package = Package(
    name: "scale",
    dependencies: [
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        .Package(url: "https://github.com/sharksync/SWSQLite.git", majorVersion: 1),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 16)
    ]
)
