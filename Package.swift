let package = Package(
    dependencies: [
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.0.0"),
    ],
    targets: [
        .target(name: myfinancesapp, dependencies: [
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        ]),
    ]
)
