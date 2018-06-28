//
//  WebService.swift
//  Kinit
//

// This networking layer is strongly inspired by:
// https://github.com/objcio/S01E08-networking-post-requests
// and https://talk.objc.io/episodes/S01E08-adding-post-requests

import Foundation

typealias JSONResult = [AnyHashable: Any]

enum WebServiceError: Error {
    case internalInconsistency
    case unexpectedData(Data)
    case malformedJSON(Error?, String?)
    case invalidStatusCode(Int)
}

enum HTTPMethod {
    case get([String: String]?)
    case post(Data?)
}

extension HTTPMethod: CustomStringConvertible {
    var description: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}

protocol WebServiceProvider: class {
    func userId() -> String?
    func deviceId() -> String?
    func appVersion() -> String?
}

protocol WebServiceProtocol {
    @discardableResult
    func load<R, T>(_ request: WebRequest<R, T>) -> URLSessionTask
    var serverHost: String { get }
    var provider: WebServiceProvider? { get set }
}

class WebService: WebServiceProtocol {
    let serverHost: String
    let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20

        return URLSession(configuration: configuration)
    }()

    weak var provider: WebServiceProvider?

    init(serverHost: String) {
        self.serverHost = serverHost
    }

    @discardableResult
    func load<R, T>(_ request: WebRequest<R, T>) -> URLSessionTask {
        let aURLRequest = urlRequest(for: request)
        let task = urlSession.dataTask(with: aURLRequest,
                                       completionHandler: dataTaskCompletion(for: request, urlRequest: aURLRequest))

        task.resume()

        return task
    }

    private func urlRequest<R, T>(for request: WebRequest<R, T>) -> URLRequest {
        var urlRequest = URLRequest(webRequest: request, host: serverHost)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-type")

        if let userId = provider?.userId() {
            urlRequest.addValue(userId, forHTTPHeaderField: "X-USERID")
        }

        if let deviceId = provider?.deviceId() {
            urlRequest.addValue(deviceId, forHTTPHeaderField: "X-DEVICEID")
        }

        if let appVersion = provider?.appVersion() {
            urlRequest.addValue(appVersion, forHTTPHeaderField: "X-APPVERSION")
        }

        return urlRequest
    }

    private typealias URLSessionDataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

    //swiftlint:disable:next line_length
    private func dataTaskCompletion<R, T>(for request: WebRequest<R, T>, urlRequest: URLRequest) -> URLSessionDataTaskCompletion {
        guard let completion = request.completion else {
            return { _, _, _ in }
        }

        #if DEBUG
            let curlString: String? = urlRequest.curlString
        #else
            let curlString: String? = nil
        #endif

        return { data, response, error in
            if let error = error {
                completion(nil, error)
                KLogError(request.path + ": " + String(describing: error))

                if let curl = curlString {
                    KLogError("You can retry this request with:\n\(curl)")
                }

                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, WebServiceError.internalInconsistency)
                return
            }

            let statusCode = response.statusCode

            guard statusCode >= 200 && statusCode < 300 else {
                KLogError(request.path + ": Invalid status code \(statusCode)")
                if let curl = curlString {
                    KLogError("You can retry this request with:\n\(curl)")
                }

                completion(nil, WebServiceError.invalidStatusCode(statusCode))
                return
            }

            guard let data = data else {
                completion(nil, WebServiceError.internalInconsistency)
                return
            }

            do {
                KLogVerbose(request.path + ": " + (String(data: data, encoding: .utf8) ?? "Bad Response"))

                let decoded = try JSONDecoder().decode(R.self, from: data)
                completion(request.transform(decoded), nil)
            } catch {
                print(error)
                print("Malformed JSON:\n\(String(data: data, encoding: .utf8) ?? "")")
                completion(nil, WebServiceError.malformedJSON(error, String(data: data, encoding: .utf8)))
            }
        }
    }
}

private extension URLRequest {
    init<R, T>(webRequest: WebRequest<R, T>, host: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = webRequest.path

        if case let .get(parameters) = webRequest.method, let params = parameters {
            urlComponents.queryItems = params.map {
                return URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        self.init(url: urlComponents.url!)
        httpMethod = String(describing: webRequest.method)

        if case let .post(body) = webRequest.method, let data = body {
            httpBody = data
        }
    }
}
