//
//  ItemsCoordinator.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 15.02.2025.
//

import UIKit

protocol ItemsCoordinatorProtocol {
    func showProductDetails(_ product: ProductDTO)
}

final class ItemsCoordinator: ItemsCoordinatorProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showProductDetails(_ product: ProductDTO) {
        let fetchUseCase: FetchProductDetailUseCaseProtocol = FetchProductDetailUseCase(
            repository: ProductRepository(networkService: NetworkService())
        )
        let addToCartUseCase: AddToCartUseCaseProtocol = AddToCartUseCase(repository: ShoppingCartRepositoryImpl())
        let checkInCartUseCase: CheckProductInCartUseCaseProtocol = CheckProductInCartUseCase(repository: ShoppingCartRepositoryImpl())
        
        let viewModel = ProductDetailViewModel(
            productId: "\(product.id)",
            fetchProductDetailUseCase: fetchUseCase,
            addToCartUseCase: addToCartUseCase,
            checkProductInCartUseCase: checkInCartUseCase
        )
        
        let detailVC = ProductDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(detailVC, animated: true)
    }

}
