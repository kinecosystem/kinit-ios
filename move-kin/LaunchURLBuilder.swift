//
//  LaunchURLBuilder.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

class LaunchURLBuilder {
    static func requestAddressURL(for app: MoveKinApp) -> URL? {
        guard app.urlScheme.isNotEmpty else {
            return nil
        }

        guard let appURLScheme = Bundle.firstAppURLScheme else {
            let message =
            """
            MoveKin couldn't find a URL scheme to be used to launch this app back and receive data from \(app.name)".
            Add a URL scheme to this app's info.plist and try again.
            """

            fatalError(message)
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = app.urlScheme
        urlComponents.host = Constants.urlHost
        urlComponents.path = Constants.requestAddressURLPath
        urlComponents.queryItems = [URLQueryItem(name: Constants.callerAppNameQueryItem, value: Bundle.appName),
                                    URLQueryItem(name: Constants.callerAppURLSchemeQueryItem, value: appURLScheme)]

        return urlComponents.url
    }

    static func provideAddressURL(address: String, urlScheme: String) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = urlScheme
        urlComponents.host = Constants.urlHost
        urlComponents.path = Constants.receiveAddressURLPath
        urlComponents.queryItems = [URLQueryItem(name: Constants.receiveAddressQueryItem, value: address)]

        return urlComponents.url!
    }
}

private extension Bundle {
    static var appName: String? {
        return main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? main.infoDictionary?["CFBundleName"] as? String
    }

    static var firstAppURLScheme: String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypesDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypesDictionary["CFBundleURLSchemes"] as? [String] else {
                return nil
        }

        return urlSchemes.first
    }
}
