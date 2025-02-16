//
//  ProductFilter.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 13.02.2025.
//

import Foundation

struct ProductFilter {
    let title: String?
    let priceMin: Double?
    let priceMax: Double?
    let categoryId: Int?
    let offset: Int
    let limit: Int
    
    init(title: String? = nil,
         priceMin: Double? = nil,
         priceMax: Double? = nil,
         categoryId: Int? = nil,
         offset: Int = 0,
         limit: Int = 10
    ) {
        self.title = title
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.categoryId = categoryId
        self.offset = offset
        self.limit = limit
    }
}
