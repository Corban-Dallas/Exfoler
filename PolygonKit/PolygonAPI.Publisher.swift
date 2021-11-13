//
//  PolygonAPI.Publisher.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 28.10.2021.
//

import Foundation
import Combine

extension PolygonAPI {
    /// A publisher sequentially provide chained output from network
    ///     firstUrl: - an url to the first json in chain
    ///     nextUrl - a key path for decoded json where url of next json is stored
    internal struct SequentialDataPublisher<Output: Decodable>: Publisher {
        let firstUrl: URL
        let nextUrl: KeyPath<Output, String?>
        
        func receive<S: Subscriber>(subscriber: S) where S.Failure == Error, S.Input == Output {
            let subscription = SequentialDataSubscription(subscriber: subscriber,
                                                            firstUrl: firstUrl,
                                                             nextUrl: nextUrl)
            subscriber.receive(subscription: subscription)
        }
        typealias Failure = Error
    }
    
    private final class SequentialDataSubscription<S: Subscriber, Output: Decodable>: Subscription where S.Input == Output, S.Failure == Error {
        var subscriber: S?

        var firstUrl: URL
        let nextUrl: KeyPath<Output, String?>
        var task: URLSessionDataTask?

        init(subscriber: S, firstUrl: URL, nextUrl: KeyPath<Output, String?>) {
            self.subscriber = subscriber
            self.firstUrl = firstUrl
            self.nextUrl = nextUrl
        }
        
        func request(_ demand: Subscribers.Demand) {
            fetchData(url: firstUrl)
        }
        
        // Recursive function to fetch and decode data page after page and to send decoded data to subscriber
        private func fetchData(url: URL) {
            print(url)
            task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    self?.subscriber?.receive(completion: .failure(error))
                } else if let data = data {
                    do {
                        let tickers = try JSONDecoder().decode(S.Input.self, from: data)
                        _ = self?.subscriber?.receive(tickers)
                        if let nextStringUrl = tickers[keyPath: self!.nextUrl] {
                            let url = URL(string: nextStringUrl + "&apiKey=c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")!
                            self?.fetchData(url: url)
                        } else {
                            self?.subscriber?.receive(completion: .finished)
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
