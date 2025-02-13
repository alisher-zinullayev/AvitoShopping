//
//  SearchProductsUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 13.02.2025.
//

import Foundation

protocol SearchProductsUseCaseProtocol {
    func execute(filter: ProductFilter) async throws -> [ProductDTO]
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {
    private let repository: SearchRepositoryProtocol

    init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }

    func execute(filter: ProductFilter) async throws -> [ProductDTO] {
        return try await repository.searchProducts(filter: filter)
    }
}
