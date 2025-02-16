//
//  FetchProductDetailUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import Foundation

protocol FetchProductDetailUseCaseProtocol {
    func execute(productId: String) async throws -> ProductDTO
}

final class FetchProductDetailUseCase: FetchProductDetailUseCaseProtocol {
    private let repository: ProductRepositoryProtocol
    
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(productId: String) async throws -> ProductDTO {
        return try await repository.getProduct(by: productId)
    }
}
