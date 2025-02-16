//
//  FavoriteProductRepositoryImpl.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import Foundation

protocol FavoriteProductRepositoryProtocol {
    func addFavorite(product: ProductDTO) throws
}

final class FavoriteProductRepositoryImpl: FavoriteProductRepositoryProtocol {
    func addFavorite(product: ProductDTO) throws {
        print("Product favorite added to cart: \(product)")
    }
}
