//
//  TickerInfo.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 03.11.2021.
//

import Foundation
import AppKit

// Структура с информацией об активах. Используется как промежуточное хранилище для моста
// между возвращаемыми данными внешнего фреймворка и локальными записями в базе данных

struct TickerInfo {
    var id = UUID()
    var ticker: String
    var name: String
    var locale: String
    var market: String
    var type: String
    var currency: String
}

extension TickerInfo: Codable, Hashable, Identifiable {
    
}
