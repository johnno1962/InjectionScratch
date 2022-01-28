// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InjectionScratch",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "InjectionScratch", type:.dynamic,
            targets: ["InjectionScratch"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "InjectionScratch",
            dependencies: ["InjectionLoader"]),
        .binaryTarget(
            name: "InjectionLoader",
            url: "https://raw.githubusercontent.com/johnno1962/InjectionScratch/main/InjectionLoader-1.0.0.zip",
            checksum: "f21a32ff846ebd5839a095c3ba1b5fc4b969cccd47161c1184bb3f4c938f5286"
        ),
    ]
)
