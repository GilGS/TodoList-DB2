import PackageDescription

let package = Package(
    name: "TodoList",
    targets: [
        Target(
            name: "Deploy",
            dependencies: [.Target(name: "TodoList")]
        ),
        Target(
            name: "TodoList"
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-DTeam/swift-for-db2",     majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",        majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",  majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/todolist-web",      majorVersion: 0, minor: 8),
        .Package(url: "https://github.com/IBM-Swift/Swift-cfenv.git",   majorVersion: 1, minor: 7)
        
    ]
)
