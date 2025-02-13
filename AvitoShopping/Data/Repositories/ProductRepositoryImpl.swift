//
//  ProductRepositoryImpl.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

protocol ProductRepositoryProtocol {
    func getProductList(offset: Int, limit: Int) async throws -> [ProductDTO]
    func getFilteredProductList(with config: NetworkConfig) async throws -> [ProductDTO]
}

final class ProductRepository: ProductRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func getProductList(offset: Int, limit: Int) async throws -> [ProductDTO] {
        let config = ProductNetworkConfig.productList(offset: offset, limit: limit)
        return try await networkService.request(with: config)
    }
    
    func getFilteredProductList(with config: NetworkConfig) async throws -> [ProductDTO] {
            return try await networkService.request(with: config)
        }
}
