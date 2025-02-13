//
//  NetworkError.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case missingURL
    case noConnect
    case invalidData
    case requestFailed
    case encodingError
    case decodingError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingURL:
            return "Missing URL."
        case .noConnect:
            return "No connection."
        case .invalidResponse:
            return "Invalid response."
        case .invalidData:
            return "Invalid data."
        case .decodingError:
            return "Decoding error."
        case .encodingError:
            return "Encoding error."
        case .requestFailed:
            return "Request failed."
        }
    }
}
