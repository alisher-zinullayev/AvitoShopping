//
//  ShoppingCartRepositoryImpl.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import Foundation

protocol ShoppingCartRepositoryProtocol {
    func addToCart(product: ProductDTO) throws
}

class ShoppingCartRepositoryImpl: ShoppingCartRepositoryProtocol {
    func addToCart(product: ProductDTO) throws {
        print("Product added to cart: \(product)")
    }
}
