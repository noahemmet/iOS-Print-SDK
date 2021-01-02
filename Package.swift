// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Kite-Print-SDK",
  platforms: [
    .iOS(.v10)
  ],
  products: [
    .library(
      name: "Kite-Print-SDK",
      targets: ["PSPrintSDK"]
    ),
  ],
  targets: [
    .target(
      name: "PSPrintSDK",
      path: "Kite-SDK/PSPrintSDK"
    ),
  ]
)
