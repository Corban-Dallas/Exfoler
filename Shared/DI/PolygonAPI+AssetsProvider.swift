//
//  PolygonAPI+AssetsProvider.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 03.11.2021.
//

import Foundation
import Combine
import PolygonKit

extension PolygonAPI: AssetsProvider {
    func tickers(search: String) -> AnyPublisher<[AssetInfo], Error> {
        PolygonAPI.tickers(search: search)
            .map { response in
                
                guard let assets = response.results else {
                    return []
                }
                return assets.map {
                    AssetInfo(ticker: $0.ticker,
                              name: $0.name,
                              locale: $0.locale,
                              market: $0.market,
                              type: $0.type ?? "N/A",
                              currency: $0.currency_name)
                }
            }
            .eraseToAnyPublisher()
    }
    func previousClose(ticker: String) -> AnyPublisher<Double, Error> {
        PolygonAPI.previousClose(ticker: ticker)
            .tryMap { response in
                switch response.status {
                case "NOT_FOUND":
                    throw PolygonAPI.PolygonError.notFound
                case "ERROR":
                    throw PolygonAPI.PolygonError.requestsExceeded
                default:
                    print(response)
                    guard let closePrice = response.results?.first?.c
                    else { throw PolygonError.emptyResponse }
                    return closePrice
                }
            }
            .eraseToAnyPublisher()
    }
//    func openClosePrice(ticker: String, date: Date? = nil) -> AnyPublisher<(openPrice:Double, closePrice:Double), Error> {
//        PolygonAPI.dailyOpenClose(ticker: ticker, date: date)
//            .map { response in
//                (response.open ?? 0.0, response.high ?? 0.0)
//            }
//            .eraseToAnyPublisher()
//    }

}
