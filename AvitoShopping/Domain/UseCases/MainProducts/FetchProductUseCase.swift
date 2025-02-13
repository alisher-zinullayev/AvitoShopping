//
//  FetchProductUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

protocol FetchProductsUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> [ProductDTO]
    func executeFiltered(filter: ProductFilter) async throws -> [ProductDTO]
}

final class FetchProductsUseCase: FetchProductsUseCaseProtocol {
    private let repository: ProductRepositoryProtocol
    
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(offset: Int, limit: Int) async throws -> [ProductDTO] {
        return try await repository.getProductList(offset: offset, limit: limit)
    }
    
    func executeFiltered(filter: ProductFilter) async throws -> [ProductDTO] {
            // Here, create a network config with filter parameters:
            let config = ProductNetworkConfig.filteredProducts(title: filter.title,
                                                               priceMin: filter.priceMin,
                                                               priceMax: filter.priceMax,
                                                               categoryId: filter.categoryId,
                                                               offset: filter.offset,
                                                               limit: filter.limit)
            // Call networkService via repository, similar to before:
            return try await repository.getFilteredProductList(with: config)
        }
}
