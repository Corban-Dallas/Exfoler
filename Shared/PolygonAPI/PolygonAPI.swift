//
//  polygonAPI.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import Foundation
import Combine

class PolygonAPI {
    static private let baseURL: String = "https://api.polygon.io"
    static private let agent = Agent()
    
    
    static func dailyOpenClose(symbol: String, date: Date? = nil) -> AnyPublisher<(openPrice: Double, closePrice: Double), Never> {
        var stringURL = baseURL
        stringURL.append("/v1/open-close/\(symbol)")
        
        let date = date ?? Calendar.current.date(byAdding: .year, value: -1, to: Date() )!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy-MM-dd"
        stringURL.append( dateFormatter.string(from: date))
                          
        stringURL.append("?adjusted=true&apiKey=c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")
        print(stringURL)
        let url = URL(string: stringURL)!
        let request = URLRequest(url: url)
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> (Double, Double) in
                let value = try JSONDecoder().decode(DailyOpenCloseResponse.self, from: result.data)
                return (value.open, value.close)
            }
            .catch { (error) -> AnyPublisher<(openPrice: Double, closePrice: Double), Never> in
                //print(error)
                return Just((openPrice: 1.0, closePrice: 1.0))
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func previousClose(ticker: String) -> AnyPublisher<PreviousCloseResponse, Error> {
        var stringURL = baseURL
        stringURL.append("/v2/aggs/ticker/\(ticker)/prev")
        stringURL.append("?adjusted=true&apiKey=c5TTKPWNlgFyYCTGgU3iLS0K93hcpWx9")
        print(stringURL)
        
        let url = URL(string: stringURL)!
        let request = URLRequest(url: url)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap(\.data)
            .decode(type: PreviousCloseResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

struct Agent {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
