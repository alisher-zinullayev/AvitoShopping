//
//  ProductDetailViewState.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import Foundation

enum ProductDetailViewState {
    case idle
    case loading
    case loaded(product: ProductDTO, isInCart: Bool)
    case error(String)
}
