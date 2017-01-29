import PackageDescription

let package = Package(
    name: "scale",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/sharksync/SQLite.swift.git", majorVersion:0)
    ]
)
