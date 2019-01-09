//
//  MoveKinApp.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

public struct MoveKinApp {
    public let name: String
    public let appStoreURL: URL
    public let bundleId: String
    public let urlScheme: String
    public let appIconURL: URL

    public init(name: String,
                appStoreURL: URL,
                bundleId: String,
                urlScheme: String,
                appIconURL: URL) {
        self.name = name
        self.appStoreURL = appStoreURL
        self.bundleId = bundleId
        self.urlScheme = urlScheme
        self.appIconURL = appIconURL
    }
}

extension MoveKinApp: Equatable {}
