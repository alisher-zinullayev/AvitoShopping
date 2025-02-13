//
//  AddToCartUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import Foundation

protocol AddToCartUseCaseProtocol {
    func execute(product: ProductDTO) throws
}

final class AddToCartUseCase: AddToCartUseCaseProtocol {
    private let repository: ShoppingCartRepositoryProtocol
    
    init(repository: ShoppingCartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(product: ProductDTO) throws {
        try repository.addToCart(product: product)
    }
}

