
// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  $Id: //depot/InjectionScratch/Package.swift#87 $
//

import PackageDescription
import Foundation

let package = Package(
    name: "InjectionScratch",
    platforms: [.iOS("10.0"), .tvOS("10.0")],
    products: [
        .library(name: "InjectionScratch", type: .dynamic, targets: ["InjectionScratch"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "InjectionScratch", dependencies: []),
    ]
)
