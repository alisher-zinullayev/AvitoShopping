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
        let items = CoreDataManager.shared.fetchCartItems()
        if let existingItem = items.first(where: { $0.productId == Int64(product.id) }) {
            let newQuantity = Int(existingItem.quantity) + 1
            CoreDataManager.shared.updateCartItemQuantity(cartItem: existingItem, newQuantity: newQuantity)
        } else {
            let position = items.count + 1
            CoreDataManager.shared.createCartItem(
                productId: product.id,
                title: product.title,
                price: product.price,
                imageUrl: product.images.first ?? "",
                quantity: 1,
                position: position
            )
        }
    }
}
