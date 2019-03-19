//
//  KinEnvironment.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation
import KinCoreSDK
//import StellarKit

//swiftlint:disable force_try

private let kinHorizonStageURL = URL(string: "https://horizon-playground.kininfrastructure.com")!

private let kinHorizonProductionURL = URL(string: "https://horizon-ecosystem.kininfrastructure.com")!
private let kinHorizonProductionIssuer = "GDF42M3IPERQCBLWFEZKQRK77JQ65SCKTU3CW36HZVCX7XX5A5QXZIVK"
private let kinHorizonProductionName = "Public Global Kin Ecosystem Network ; June 2018"

//swiftlint:enable force_try

class KinEnvironment {
    static func kinClient() -> KinClient {
        let url: URL
        let kinNetworkId: KinCoreSDK.NetworkId

        #if DEBUG || RELEASE_STAGE
        url = kinHorizonStageURL
        kinNetworkId = .playground
        #else
        url = kinHorizonProductionURL
        kinNetworkId = .custom(issuer: kinHorizonProductionIssuer, stellarNetworkId: .custom(kinHorizonProductionName))
        #endif

        return KinClient(with: url, networkId: kinNetworkId)
    }
}
