//
//  NetworkConfig.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

protocol NetworkConfig {
    var path: String { get }
    var endPoint: String { get }
    var task: HTTPTask { get }
    var method: HTTPMethod { get }
}
