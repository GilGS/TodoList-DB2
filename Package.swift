import PackageDescription

let package = Package(
    name: "todolist-db2",
    dependencies: [
        .Package(url: "https://github.com/IBM-DTeam/swift-for-db2.git", majorVersion: 1)
    ]
)
