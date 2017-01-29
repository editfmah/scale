import PackageDescription

let package = Package(
    name: "scale",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/Swift-Kuery.git", majorVersion: 0),
        .Package(url: "https://github.com/sharksync/Swift-Kuery-SQLite.git", majorVersion: 0)
    ]
)
