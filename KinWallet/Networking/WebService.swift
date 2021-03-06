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
    case transformedValueNil
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
    func headers() -> [String: String]?
}

protocol WebServiceProtocol {
    @discardableResult
    func load<R, T>(_ request: WebRequest<R, T>) -> URLSessionTask
    var serverHost: String { get }
    var provider: WebServiceProvider? { get set }
}

extension WebServiceProtocol {
    var baseURL: URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = serverHost

        return urlComponents.url!
    }
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

        provider?.headers()?.forEach { (headerName, value) in
            urlRequest.addValue(value, forHTTPHeaderField: headerName)
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
                completion(.failure(error))
                KLogError(request.path + ": " + String(describing: error))

                if let curl = curlString {
                    KLogError("You can retry this request with:\n\(curl)")
                }

                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(WebServiceError.internalInconsistency))
                return
            }

            let statusCode = response.statusCode

            guard statusCode >= 200 && statusCode < 300 else {
                KLogError(request.path + ": Invalid status code \(statusCode)")
                if let curl = curlString {
                    KLogError("You can retry this request with:\n\(curl)")
                }

                completion(.failure(WebServiceError.invalidStatusCode(statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(WebServiceError.internalInconsistency))
                return
            }

            do {
                KLogVerbose(request.path + ": " + (String(data: data, encoding: .utf8) ?? "Bad Response"))

                let decoded = try JSONDecoder().decode(R.self, from: data)
                if let transformedValue = request.transform(decoded) {
                    completion(.success(transformedValue))
                } else {
                    completion(.failure(WebServiceError.transformedValueNil))
                }
            } catch {
                print(error)
                print("Malformed JSON:\n\(String(data: data, encoding: .utf8) ?? "")")
                let wError = WebServiceError.malformedJSON(error, String(data: data, encoding: .utf8))
                completion(.failure(wError))
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
