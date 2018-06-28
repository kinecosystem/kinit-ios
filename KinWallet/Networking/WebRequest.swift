//
//  WebRequest.swift
//  Kinit
//

import Foundation

class WebRequest<Result: Codable, Transform> {
    typealias WebRequestCompletion = ((Transform?, Error?) -> Void)

    let path: String
    let method: HTTPMethod
    let transform: (Result?) -> Transform?
    var completion: WebRequestCompletion?

    init(GET path: String,
         params: [String: String]? = nil,
         transform: @escaping (Result?) -> Transform?,
         completion: WebRequestCompletion? = nil) {
        self.path = path
        self.method = .get(params)
        self.transform = transform
        self.completion = completion
    }

    init<B>(POST path: String,
            body: B,
            transform: @escaping (Result?) -> Transform?,
            completion: WebRequestCompletion? = nil) where B: Codable {
        self.path = path
        self.method = .post(try? JSONEncoder().encode(body))
        self.transform = transform
        self.completion = completion
    }
}

extension WebRequest {
    func requestURL(with serverURL: URL) -> URL {
        return serverURL.appendingPathComponent(path)
    }

    func withCompletion(_ completion: @escaping WebRequestCompletion) -> WebRequest {
        self.completion = completion

        return self
    }

    func load(with webService: WebServiceProtocol) {
        webService.load(self)
    }
}
