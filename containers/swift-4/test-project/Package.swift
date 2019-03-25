/*-----------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See LICENSE in the project root for license information.
 *---------------------------------------------------------------------------------------*/

// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "helloworld",
    targets: [
        .target(
            name: "helloworld",
            path: "Sources")
    ]
)