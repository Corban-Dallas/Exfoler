//
//  polygonAPI.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import Foundation
import Combine

class PolygonAPI {
    static private let agent = Agent()
    static private let urlComponents: URLComponents = {
        var uc = URLComponents()
        uc.scheme = "https"
        uc.host = "api.polygon.io"
        uc.queryItems = [URLQueryItem(name: "apiKey", value: "c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")]
        return uc
    }()
    
    
    static func tickers(search: String) -> AnyPublisher<TickersResponse, Error> {
        var uc = urlComponents
        uc.path = "/v3/reference/tickers"
        uc.queryItems!.append(contentsOf: [
            URLQueryItem(name: "search", value: search),
            URLQueryItem(name: "active", value: "true"),
            URLQueryItem(name: "sort", value: "ticker"),
            URLQueryItem(name: "order", value: "asc"),
            URLQueryItem(name: "limit", value: "10"),
            ])
        let url = uc.url!
        print(url)

        let request = URLRequest(url: url)
        return agent.run(request)
    }
    
    static func dailyOpenClose(symbol: String, date: Date? = nil) -> AnyPublisher<DailyOpenCloseResponse, Error> {
        var uc = urlComponents
        uc.path = "/v1/open-close/\(symbol)"

        let date = date ?? Calendar.current.date(byAdding: .year, value: -1, to: Date() )!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy-MM-dd"
        uc.path = dateFormatter.string(from: date)
                          
        let request = URLRequest(url: uc.url!)
        return agent.run(request)
    }
    
    static func previousClose(ticker: String) -> AnyPublisher<PreviousCloseResponse, Error> {
        var uc = urlComponents
        uc.path = "/v2/aggs/ticker/\(ticker)/prev"
        
        let request = URLRequest(url: uc.url!)
        return agent.run(request)
    }
    
}

struct Agent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}