//
//  AssetsProvider.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 03.11.2021.
//

import Foundation
import Combine

/// Bridge protocol beetwen external assets data provider and Exfoler
protocol AssetsProvider {
    func tickers(search: String) -> AnyPublisher<[AssetInfo], Error>
    func previousClose(ticker: String) -> AnyPublisher<Double, Error>
//    func openClosePrice(ticker: String, date: Date?) -> AnyPublisher<(openPrice:Double, closePrice:Double), Error>
}
