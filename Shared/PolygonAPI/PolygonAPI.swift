//
//  polygonAPI.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import Foundation
import Combine
import SwiftUI

public class PolygonAPI {
    public static let shared = PolygonAPI()
    private init() { }
    
    static private let publisherAgent = PublisherAgent()
    static private let clouserAgent = ClouserAgent()
    
    static internal let urlComponents: URLComponents = {
        var uc = URLComponents()
        uc.scheme = "https"
        uc.host = "api.polygon.io"
        uc.queryItems = [URLQueryItem(name: "apiKey", value: "c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")]
        return uc
    }()
    
    public static func tickers(search: String, complition: @escaping (TickersResponse?, Error?) -> Void) {
        var uc = urlComponents
        uc.path = "/v3/reference/tickers"
        uc.queryItems!.append(contentsOf: [
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "active", value: "true"),
            URLQueryItem(name: "sort", value: "name"),
            URLQueryItem(name: "order", value: "asc"),
        ])
        guard let url = uc.url else { return }
        print(url)
        let request = URLRequest(url: url)
        clouserAgent.run(request, complition: complition)
    }

    public static func tickers(search: String) -> AnyPublisher<TickersResponse, Error> {
        var uc = urlComponents
        uc.path = "/v3/reference/tickers"
        uc.queryItems!.append(contentsOf: [
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "active", value: "true"),
            URLQueryItem(name: "sort", value: "name"),
            URLQueryItem(name: "order", value: "asc"),
            URLQueryItem(name: "limit", value: "20"),
        ])

        return SequentialDataPublisher(firstUrl: uc.url!, nextUrl: \.next_url)
            .eraseToAnyPublisher()
    }

        
    public static func dailyOpenClose(ticker: String, date: Date? = nil) -> AnyPublisher<DailyOpenCloseResponse, Error> {
        var uc = urlComponents
//        uc.path = "/v1/open-close/\(ticker)"

        let date = date ?? Calendar.current.date(byAdding: .year, value: -1, to: Date() )!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy-MM-dd"
        uc.path = "/v1/open-close/\(ticker)" + dateFormatter.string(from: date)
        let request = URLRequest(url: uc.url!)
        return publisherAgent.run(request)
    }
    
    public static func previousClose(ticker: String) -> AnyPublisher<PreviousCloseResponse, Error> {
        var uc = urlComponents
        uc.path = "/v2/aggs/ticker/\(ticker)/prev"
        let request = URLRequest(url: uc.url!)
        return publisherAgent.run(request)
    }
    
    public static func previousClose(ticker: String, complition: @escaping (PreviousCloseResponse?, Error?) -> Void ) {
        var uc = urlComponents
        uc.path = "/v2/aggs/ticker/\(ticker)/prev"
        let request = URLRequest(url: uc.url!)
        clouserAgent.run(request) { response, error in
            complition(response, error)
        }
    }
    
    public enum PolygonError: String, Error {
        case notFound = "Data not found"
        case requestsExceeded = "You've exceeded the maximum requests per minute, please wait or upgrade your subscription to continue. https://polygon.io/pricing"
        case emptyResponse
    }
    
}

private struct PublisherAgent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

private struct ClouserAgent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    func run<T: Decodable>(_ request: URLRequest, complition: @escaping (T?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                complition(nil, error)
                return
            }
            guard let data = data
            else { return }
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                complition(response, nil)
            } catch {
                complition(nil, error)
            }
        }
        .resume()
    }
    
}
