//
//  NetworkOperation.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class NetworkOperation<T: Decodable>: AsyncOperation {

    typealias NetworkCompletion = (_ result: Result<T>, _ statusCode: Int?) -> Void

    var result: Result<T> = .error(nil)
    fileprivate var request: NetworkRequest
    fileprivate var responseCode: Int?

    init(with request: NetworkRequest, responseHandler: @escaping NetworkCompletion) {
        self.request = request
        super.init()

        addCompletionHandler { [weak self] in
            guard let this = self else { return }
            responseHandler(
                this.result,
                this.responseCode
            )
        }
    }

    public override func execute(finish: @escaping () -> Void) {
        guard let urlRequest = request.URLRequest() else { return }

        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let this = self else { return }

            if let httpResponse = response as? HTTPURLResponse {
                this.responseCode = httpResponse.statusCode
            }

            if let payload = data, error == nil {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let final = try decoder.decode(T.self, from: payload)

                    this.result = .success(final)
                } catch let err {
                    this.result = .error(err)
                }
            }

            if let error = error {
                this.result = .error(error)
            }

            finish()
        }

        task.resume()
    }
}
