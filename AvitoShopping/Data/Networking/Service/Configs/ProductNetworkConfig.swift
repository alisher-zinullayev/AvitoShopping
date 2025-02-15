//
//  ProductNetworkConfig.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

enum ProductNetworkConfig: NetworkConfig {
    case productList(offset: Int, limit: Int)
    case filteredProducts(title: String?, priceMin: Double?, priceMax: Double?, categoryId: Int?, offset: Int, limit: Int)
    
    var path: String {
        return "products"
    }
    
    var endPoint: String {
        switch self {
        case .productList(let offset, let limit):
            return "?offset=\(offset)&limit=\(limit)"
            
        case .filteredProducts(let title, let priceMin, let priceMax, let categoryId, let offset, let limit):
            var queryItems: [URLQueryItem] = []
            
            if let title = title, !title.isEmpty {
                let keywords = title.split(separator: " ").map(String.init)
                for keyword in keywords {
                    queryItems.append(URLQueryItem(name: "title", value: keyword))
                }
            }
            
            if let priceMin = priceMin {
                queryItems.append(URLQueryItem(name: "price_min", value: "\(Int(priceMin))"))
            }
            
            if let priceMax = priceMax {
                queryItems.append(URLQueryItem(name: "price_max", value: "\(Int(priceMax))"))
            }
            
            if let categoryId = categoryId {
                queryItems.append(URLQueryItem(name: "categoryId", value: "\(categoryId)"))
            }
            
            queryItems.append(URLQueryItem(name: "offset", value: "\(offset)"))
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
            
            var components = URLComponents()
            components.queryItems = queryItems
            return components.percentEncodedQuery.map { "?\($0)" } ?? ""
        }
    }
    
    var task: HTTPTask {
        return .request
    }
    
    var method: HTTPMethod {
        return .get
    }
}
