//
//  ProductNetworkConfig.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

enum ProductNetworkConfig: NetworkConfig {
    case productList(offset: Int, limit: Int)
    
    var path: String {
        return "products"
    }
    
    var endPoint: String {
        switch self {
        case .productList(let offset, let limit):
            return "?offset=\(offset)&limit=\(limit)"
        }
    }
    
    var task: HTTPTask {
        return .request
    }
    
    var method: HTTPMethod {
        return .get
    }
}
