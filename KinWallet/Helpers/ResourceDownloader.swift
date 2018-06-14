//
//  ResourceDownloader.swift
//  Kinit
//

import UIKit

typealias ResourceCompletion = (URL?, ResourceOrigin?, Error?) -> Void
typealias ResourceRequestCompletion = (URL?, Error?) -> Void

enum ResourceOrigin {
    case localCache
    case remote
}

enum ResourceError: Error {
    case inconsistentState
    case encodingFailed
    case copyFailed
    case directoryCreationFailed
    case nonHTTPResponse
    case requestFailed(Int)
}

private class CompletionsBox {
    var completions = [ResourceCompletion]()

    init(_ completions: [ResourceCompletion]) {
        self.completions = completions
    }
}

class ResourceDownloader {
    static let shared = ResourceDownloader()
    let fileManager = FileManager.default
    let cacheName = "ImagesCache"

    var cacheURL: URL {
        return fileManager.urls(for: .cachesDirectory,
                                in: .userDomainMask)[0]
            .appendingPathComponent(cacheName)
    }

    fileprivate var pendingRequests = [String: CompletionsBox]()

    let queue = DispatchQueue(label: "com.KinFoundation.Standalone.ResourceDownloader")

    func requestResource(url: URL) {
        requestResource(url: url, completion: nil)
    }

    func requestResource(url: URL, completion: ResourceCompletion?) {
        if !createDirectoryIfNeeded() {
            completion?(nil, nil, ResourceError.directoryCreationFailed)
            return
        }

        guard let rID = url.absoluteString.urlEncoded else {
            completion?(nil, nil, ResourceError.encodingFailed)

            return
        }

        if fileManager.fileExists(atPath: cacheURL.appendingPathComponent(rID).path) {
            completion?(cacheURL.appendingPathComponent(rID), .localCache, nil)

            return
        }

        queue.async {
            if
                let box = self.pendingRequests[rID],
                let completion = completion {
                box.completions.append(completion)
                return
            }

            let completions = completion != nil ? [completion!] : []
            self.pendingRequests[rID] = CompletionsBox(completions)

            self.issueRequest(url: url) { tempURL, error in
                self.queue.sync {
                    let box = self.pendingRequests[rID]

                    defer {
                        self.queue.async {
                            self.pendingRequests.removeValue(forKey: rID)
                        }
                    }

                    if let error = error {
                        KLogError("Request failed: \(url.absoluteString)")
                        box?.completions.forEach { $0(nil, nil, error) }

                        return
                    }

                    guard let tempURL = tempURL else {
                        box?.completions.forEach { $0(nil, nil, ResourceError.inconsistentState) }

                        return
                    }

                    do {
                        let to = self.cacheURL.appendingPathComponent(rID)

                        try self.fileManager.copyItem(at: tempURL, to: to)

                        box?.completions.forEach { $0(to, .remote, nil) }
                    } catch {
                        box?.completions.forEach { $0(nil, nil, ResourceError.copyFailed) }
                    }
                }
            }
        }
    }

    func issueRequest(url: URL, completion: @escaping ResourceRequestCompletion) {
        URLSession.shared.downloadTask(with: url, completionHandler: { url, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, ResourceError.nonHTTPResponse)
                return
            }

            if response.statusCode < 200 || response.statusCode >= 300 {
                completion(nil, ResourceError.requestFailed(response.statusCode))
            } else {
                completion(url, error)
            }
        }).resume()
    }

    fileprivate func createDirectoryIfNeeded() -> Bool {
        if fileManager.fileExists(atPath: cacheURL.path) {
            return true
        }

        let success: Bool
        do {
            try fileManager.createDirectory(at: cacheURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            success = true
        } catch {
            success = false
        }

        return success
    }
}
