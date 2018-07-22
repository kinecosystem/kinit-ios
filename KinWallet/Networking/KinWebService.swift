//
//  StagingService.swift
//  Kinit
//

import Foundation

private let alternateServerIdentifierKey = "kin.alternateServerIdentifier"

protocol IdentifiableWebService {
    static var identifier: String { get }
    var identifier: String { get }
}

typealias IdentifiableWebServiceProtocol = WebServiceProtocol & IdentifiableWebService

final class KinWebService {
    static let shared: IdentifiableWebServiceProtocol = {
        var service: IdentifiableWebServiceProtocol

        func defaultService() -> IdentifiableWebServiceProtocol {
            #if DEBUG || RELEASE_STAGE
                return KinStagingService.shared
            #else
                return KinProductionService.shared
            #endif
        }

        if let alternateIdentifier = UserDefaults.standard.object(forKey: alternateServerIdentifierKey) as? String {
            if alternateIdentifier == KinStagingService.identifier {
                service = KinStagingService.shared
            } else if alternateIdentifier == KinProductionService.identifier {
                service = KinProductionService.shared
            } else {
                service = defaultService()
            }
        } else {
            service = defaultService()
        }

        service.provider = AppDelegate.shared

        KLogVerbose("Initializing \(service.identifier) service at \(service.serverHost)")

        return service
    }()

    static func setAlternateService(type: IdentifiableWebService.Type) {
        //synchronize is usually not necessary anymore but as we
        //are aborting the app to reload user and account, just call
        //it now to make sure the new server identifier is persisted
        UserDefaults.standard.set(type.identifier, forKey: alternateServerIdentifierKey)
        UserDefaults.standard.synchronize()

        SimpleDatastore.deleteAll()

        _ = [][42]
    }
}

final class KinStagingService: WebService, IdentifiableWebService {
    static var identifier: String {
        return "Staging"
    }

    var identifier: String {
        return type(of: self).identifier
    }

    static let shared = KinStagingService(serverHost: Configuration.shared.serverHostStage)
}

final class KinProductionService: WebService, IdentifiableWebService {
    static var identifier: String {
        return "Production"
    }

    var identifier: String {
        return type(of: self).identifier
    }

    static let shared = KinProductionService(serverHost: Configuration.shared.serverHostProd)
}
