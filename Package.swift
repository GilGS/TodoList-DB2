import PackageDescription

let package = Package(
    name: "TodoList",
    dependencies: [
        .Package(url: "https://github.com/IBM-DTeam/swift-for-db2.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/todolist-api", majorVersion: 0, minor: 3)
    ]
)
