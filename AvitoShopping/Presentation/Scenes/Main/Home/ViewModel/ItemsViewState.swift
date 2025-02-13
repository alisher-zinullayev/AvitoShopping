//
//  ItemsViewState.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import Foundation

enum ItemsViewState {
    case idle
    case loading
    case loaded(ViewData)
    case error(String)
}

struct ViewData {
    let products: [ProductItemViewModel]
}

struct ProductItemViewModel {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let imageUrl: String
}
