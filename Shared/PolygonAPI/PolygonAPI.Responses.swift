//
//  PolygonAPI.Responses.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import Foundation

extension PolygonAPI {
    struct DailyOpenCloseResponse: Decodable {
        let status: String
        let from: Date
        let symbol: String
        let open: Double
        let high: Double
        let low: Double
        let close: Double
        let volume: Double
        let afterHours: Double
        let preMarket: Double
    }
    
    struct PreviousCloseResponse: Decodable {
        let ticker: String
        let queryCount: Int
        let resultsCount: Int
        let adjusted: Bool
        let results: [Results]
        let request_id: String
        let status: String
    
        struct Results: Decodable {
            let T: String
            let c: Double
            let h: Double
            let l: Double
            let o: Double
            let t: Int
            let v: Int
            let vw: Double
        }
    }
}
