//
//  SearchRepositoryImpl.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 13.02.2025.
//

import Foundation

protocol SearchRepositoryProtocol {
    func searchProducts(filter: ProductFilter) async throws -> [ProductDTO]
}

final class SearchRepositoryImpl: SearchRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func searchProducts(filter: ProductFilter) async throws -> [ProductDTO] {
        let config = ProductNetworkConfig.filteredProducts(title: filter.title,
                                                           priceMin: filter.priceMin,
                                                           priceMax: filter.priceMax,
                                                           categoryId: filter.categoryId,
                                                           offset: filter.offset,
                                                           limit: filter.limit)
        return try await networkService.request(with: config)
    }
}
