//
//  HomebrewExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol HomebrewExchangeAPI {
    func nextPage(fromTimestamp: Date, completion: @escaping ExchangeCompletion)
    func cancel()
    func isExecuting() -> Bool
}

class HomebrewExchangeService: HomebrewExchangeAPI {

    fileprivate var task: URLSessionDataTask?

    func nextPage(fromTimestamp: Date, completion: @escaping ExchangeCompletion) {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else { return }
        let timestamp = DateFormatter.sessionDateFormat.string(from: fromTimestamp)
        guard let endpoint = URL.endpoint(baseURL, pathComponents: ["trades"], queryParameters: ["before": timestamp]) else { return }
        guard let session = NetworkManager.shared.session else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            HttpHeaderField.contentType: HttpHeaderValue.json,
            HttpHeaderField.accept: HttpHeaderValue.json
        ]
        if let currentTask = task {
            guard currentTask.currentRequest != request else { return }
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let result = data {
                do {
                    let decoder = JSONDecoder()
                    let final = try decoder.decode([ExchangeTradeCellModel].self, from: result)
                    completion(final, error)
                } catch let err {
                    completion(nil, err)
                }
            }

            if let err = error {
                completion(nil, err)
            }
        })

        task?.resume()
    }

    func cancel() {
        guard let current = task else { return }
        current.cancel()
    }

    func isExecuting() -> Bool {
        return task?.state == .running
    }
}
