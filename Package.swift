import PackageDescription

let package = Package(
    name: "Hello",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/redis-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/auth-provider", majorVersion: 1)
        
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

