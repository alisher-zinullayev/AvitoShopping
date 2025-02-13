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
}
