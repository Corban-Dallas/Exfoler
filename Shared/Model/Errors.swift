//
//  Errors.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 17.11.2021.
//

import Foundation

public enum ExfolerError: Error {
    case tickerNotFound, responseIsEmpty, requestsExceeded
}
