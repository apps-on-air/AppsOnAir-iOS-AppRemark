// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AppsOnAir-AppRemark",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "AppsOnAir-AppRemark",
            targets: ["AppsOnAir-AppRemark", "AppsOnAir-AppRemark-ObjC"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/hackiftekhar/IQKeyboardToolbarManager.git",
            exact: "1.1.5"
        ),
        .package(
            url: "https://github.com/jriosdev/iOSDropDown.git",
            exact: "0.4.0"
        ),
        .package(
            url: "https://github.com/scalessec/Toast-Swift.git",
            exact: "5.1.1"
        ),
        .package(
            url: "https://github.com/logicwind/LWPhotoEditor.git",
            exact: "0.2.0"
        ),
        .package(
            url: "https://github.com/apps-on-air/AppsOnAir-iOS-Core.git",
            exact: "1.2.0"
        ),
    ],
    targets: [
        .target(
            name: "AppsOnAir-AppRemark",
            dependencies: [
                .product(name: "IQKeyboardToolbarManager", package: "IQKeyboardToolbarManager"),
                .product(name: "iOSDropDown", package: "iOSDropDown"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "LWPhotoEditor", package: "LWPhotoEditor"),
                .product(name: "AppsOnAir-Core", package: "AppsOnAir-iOS-Core"),
            ],
            path: "AppsOnAir-AppRemark",
            exclude: [
                "Assets/AppRemarkInfo.plist"
            ],
            sources: ["Classes"],
            resources: [
                // Compiled asset catalogue → Assets.car in Bundle.module
                .process("Assets/assets.xcassets"),
                // Compiled storyboard
                .process("Assets/AppRemark.storyboard"),
                // Compiled XIBs
                .process("Assets/ImageViewCell.xib"),
                .process("Assets/AddImageCVCell.xib"),
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        ),
        .target(
            name: "AppsOnAir-AppRemark-ObjC",
            dependencies: ["AppsOnAir-AppRemark"],
            path: "AppsOnAir_AppRemark_ObjC",
            publicHeadersPath: "include"
        ),
    ]
)
