//
//  FilterViewModel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import Foundation

final class FilterViewModel {
    var title: String?
    var priceMin: String?
    var priceMax: String?
    var selectedCategoryId: Int?
    
    func currentFilter() -> ProductFilter {
        return ProductFilter(
            title: title,
            priceMin: Double(priceMin ?? ""),
            priceMax: Double(priceMax ?? ""),
            categoryId: selectedCategoryId,
            offset: 0,
            limit: 10
        )
    }
}
