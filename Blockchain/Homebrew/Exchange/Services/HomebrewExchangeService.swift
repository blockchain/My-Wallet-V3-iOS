//
//  HomebrewExchangeService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// `Page` isn't ideal but, the way we page means we need to know
/// what the maximum number of items we could receive per page is.
/// Only by knowing the pageSize and comparing it to the result can
/// we determine if there are more items that need to be fetched.
struct Page<T> {
    let pageSize: Int
    let error: Error?
    let result: T?
}

protocol HomebrewExchangeAPI {
    func nextPage(fromTimestamp: Date, completion: @escaping (Page<[ExchangeTradeCellModel]>) -> ())
    func cancel()
    func isExecuting() -> Bool
}

class HomebrewExchangeService: HomebrewExchangeAPI {

    fileprivate var task: URLSessionDataTask?

    func nextPage(fromTimestamp: Date, completion: @escaping (Page<[ExchangeTradeCellModel]>) -> ()) {
        guard let baseURL = URL(string: BlockchainAPI.shared.retailCoreUrl) else { return }
        let timestamp = DateFormatter.sessionDateFormat.string(from: fromTimestamp)
        guard let endpoint = URL.endpoint(baseURL, pathComponents: ["trades"], queryParameters: ["before": timestamp]) else { return }
        guard let session = NetworkManager.shared.session else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Content-Type":"application/json",
                                       "Accept": "application/json"]
        if let currentTask = task {
            guard currentTask.currentRequest != request else { return }
        }

        task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let result = data {
                do {
                    let decoder = JSONDecoder()
                    let final = try decoder.decode([ExchangeTradeCellModel].self, from: result)
                    let page = Page(
                        pageSize: 50,
                        error: error,
                        result: final
                    )
                    completion(page)
                } catch let err {
                    let page = Page<[ExchangeTradeCellModel]>(
                        pageSize: 50,
                        error: err,
                        result: nil
                    )
                    completion(page)
                }
            }

            if let err = error {
                let page = Page<[ExchangeTradeCellModel]>(
                    pageSize: 50,
                    error: err,
                    result: nil
                )
                completion(page)
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
