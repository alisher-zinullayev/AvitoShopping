//
//  CheckProductInCartUseCase.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import Foundation

protocol CheckProductInCartUseCaseProtocol {
    func execute(productId: String) async throws -> Bool
}

final class CheckProductInCartUseCase: CheckProductInCartUseCaseProtocol {
    private let repository: ShoppingCartRepositoryProtocol
    
    init(repository: ShoppingCartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(productId: String) async throws -> Bool {
        let items = CoreDataManager.shared.fetchCartItems()
        if let idInt = Int(productId) {
            return items.contains { $0.productId == Int64(idInt) }
        }
        return false
    }
}
