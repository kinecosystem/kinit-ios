//
//  MoveKinApp.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

public struct MoveKinApp {
    let appName: String
    let appStoreURL: URL
    let bundleId: String
    let urlScheme: String
    let appIconURL: URL
}

extension MoveKinApp: Equatable {}

extension MoveKinApp {
    var requestKinAddressURL: URL? {
        guard urlScheme.isNotEmpty else {
            return nil
        }

        let urlString = "\(urlScheme)://\(MoveKinConstants.urlHost)/\(MoveKinConstants.requestAddressURLPath)"
        return URL(string: urlString)
    }
}
