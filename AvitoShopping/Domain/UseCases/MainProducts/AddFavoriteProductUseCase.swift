//
//  AddFavoriteProductUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 12.02.2025.
//

import Foundation

protocol AddFavoriteProductUseCaseProtocol {
    func execute(product: ProductDTO) throws
}

class AddFavoriteProductUseCase: AddFavoriteProductUseCaseProtocol {
    private let repository: FavoriteProductRepositoryProtocol
        
    init(repository: FavoriteProductRepositoryProtocol) {
        self.repository = repository
    }
        
    func execute(product: ProductDTO) throws {
        try repository.addFavorite(product: product)
    }
}
