//
//  PolygonAPI.Publisher.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 28.10.2021.
//

import Foundation
import Combine

extension PolygonAPI {
    struct TickersPublisher: Publisher {
        let search: String
        
        func receive<S: Subscriber>(subscriber: S) where Error == S.Failure, Output == S.Input {
            let subscription = TickersSubscription(subscriber: subscriber, search: search)
            subscriber.receive(subscription: subscription)
        }
        typealias Output = TickersResponse
        typealias Failure = Error
    }
    
    private final class TickersSubscription<S: Subscriber>: Subscription where S.Input == TickersResponse, S.Failure == Error {
        let search: String
        var nextPageUrl: URL? = nil
        var task: URLSessionDataTask?

        var subscriber: S?

        init(subscriber: S, search: String) {
            self.subscriber = subscriber
            self.search = search
        }
        
        func request(_ demand: Subscribers.Demand) {
            var uc = urlComponents
            uc.path = "/v3/reference/tickers"
            uc.queryItems!.append(contentsOf: [
                URLQueryItem(name: "search", value: search),
                URLQueryItem(name: "active", value: "true"),
                URLQueryItem(name: "sort", value: "ticker"),
                URLQueryItem(name: "order", value: "asc"),
                URLQueryItem(name: "limit", value: "10"),
                ])
            
            print("Fetch first page")
            fetchData(url: uc.url!)
        }
        
        // Recursive function to fetch tickers page after page and to send tickers to subscriber
        private func fetchData(url: URL) {
            print(url)
            task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    self?.subscriber?.receive(completion: .failure(error))
                } else if let data = data {
                    do {
                        let tickers = try JSONDecoder().decode(S.Input.self, from: data)
                        _ = self?.subscriber?.receive(tickers)
                        if tickers.next_url == nil {
                            self?.subscriber?.receive(completion: .finished)
                        } else {
                            let url = URL(string: tickers.next_url! + "&apiKey=c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")!
                            self?.fetchData(url: url)
                        }
                    } catch {
                        self?.subscriber?.receive(completion: .failure(error))
                    }
                }
            }
            task?.resume()
        }
        
        func cancel() {
            task?.cancel()
            task = nil
            subscriber = nil
        }
        
        
    }
}
