//
//  XDRCodable+Extensions.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import protocol KinSDK.XDREncodable
import protocol KinSDK.XDRDecodable
import class KinSDK.XDREncoder
import class KinSDK.XDRDecoder

extension XDREncodable {
    var asBase64String: String? {
        guard let data = try? XDREncoder.encode(self) else {
            return nil
        }

        return data.base64EncodedString()
    }
}

extension XDRDecodable {
    static func fromBase64String(string: String) -> Self? {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }

        return try? XDRDecoder.decode(self, data: data)
    }
}
