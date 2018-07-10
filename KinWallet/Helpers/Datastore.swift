//
//  Datastore.swift
//  Kinit
//

import Foundation
import KinUtil

protocol Persistable: Encodable {
    var identifier: String { get }
}

protocol Datastore {
    static func persist<T: Persistable>(_ object: T)
    static func persist<T: Encodable>(_ object: T, with identifier: String)
    static func loadObject<T: Codable>(_ identifier: String, completion: @escaping (T?) -> Void)
    static func loadObject<T: Codable>(_ identifier: String) -> T?
    static func delete<T: Persistable>(_ object: T) -> Promise<Bool>
    static func delete(objectOf type: Any.Type, with identifier: String) -> Promise<Bool>
    static func deleteAll()
}

extension Datastore {
    static func persist<T: Persistable>(_ object: T) {
        persist(object, with: object.identifier)
    }
}

struct SimpleDatastore {
    static let fileManager = FileManager.default
    static let datastoreDirectoryName = "Datastore"
    static let queue = DispatchQueue(label: "com.KinFoundation.KinWallet.SimpleDatastore")

    static var datastoreURL: URL {
        return fileManager.urls(for: .documentDirectory,
                                in: .userDomainMask)[0]
            .appendingPathComponent(datastoreDirectoryName)
    }

    fileprivate static func createDirectoryIfNeeded(for object: Any) {
        let url = datastoreURL.appendingPathComponent(String(describing: type(of: object)))

        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }

    static func url(for type: Any.Type, with identifier: String) -> URL {
        return datastoreURL
            .appendingPathComponent(String(describing: type))
            .appendingPathComponent(identifier)
    }
}

extension SimpleDatastore: Datastore {
    static func persist<T: Encodable>(_ object: T, with identifier: String) {
        queue.async {
            guard let jsonData = try? JSONEncoder().encode(object) else {
                return
            }

            createDirectoryIfNeeded(for: object)
            let destinationURL = url(for: type(of: object), with: identifier)
            try? jsonData.write(to: destinationURL)
        }
    }

    static func loadObject<T>(_ identifier: String, completion: @escaping (T?) -> Void) where T: Codable {
        queue.async {
            completion(loadObject(identifier))
        }
    }

    static func loadObject<T: Codable>(_ identifier: String) -> T? {
        let sourceURL = url(for: T.self, with: identifier)
        
        guard let data = fileManager.contents(atPath: sourceURL.path) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            KLogError("Error decoding \(T.self): \(error)")
            return nil
        }
    }

    @discardableResult
    static func delete<T>(_ object: T) -> Promise<Bool> where T: Persistable {
        return delete(objectOf: T.self, with: object.identifier)
    }

    @discardableResult
    static func delete(objectOf type: Any.Type, with identifier: String) -> Promise<Bool> {
        let p = Promise<Bool>()
        queue.async {
            let sourceURL = url(for: type, with: identifier)

            do {
                try fileManager.removeItem(at: sourceURL)
                p.signal(true)
            } catch {
                p.signal(error)
            }
        }

        return p
    }

    static func deleteAll() {
        try? fileManager.removeItem(at: datastoreURL)
    }
}
