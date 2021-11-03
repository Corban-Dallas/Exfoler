//
//  PolygonAPI.Responses.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import Foundation

public extension PolygonAPI {
    struct TickersResponse: Decodable, Hashable {
        public let status: String
        public let request_id: String
        public let error: String?
        public let count: Int?
        public let results: [Results]?
        public var next_url: String?
        
        public struct Results: Decodable, Hashable {
            public let ticker: String
            public let name: String
            public let market: String
            public let locale: String
            public let primary_exchange: String
            public let type: String?
            public let active: Bool
            public let currency_name: String
            public let cik: String?
            public let composite_figi: String?
            public let share_class_figi: String?
            public let last_updated_utc: String
        }
    }
    
    struct DailyOpenCloseResponse: Decodable {
        public let status: String
        public let from: Date
        public let symbol: String
        public let open: Double
        public let high: Double
        public let low: Double
        public let close: Double
        public let volume: Double
        public let afterHours: Double
        public let preMarket: Double
    }
    
    struct PreviousCloseResponse: Decodable {
        public let ticker: String
        public let queryCount: Int
        public let resultsCount: Int
        public let adjusted: Bool
        public let results: [Results]
        public let request_id: String
        public let status: String
    
        public struct Results: Decodable {
            public let T: String
            public let c: Double
            public let h: Double
            public let l: Double
            public let o: Double
            public let t: Int
            public let v: Int
            public let vw: Double
        }
    }
}
