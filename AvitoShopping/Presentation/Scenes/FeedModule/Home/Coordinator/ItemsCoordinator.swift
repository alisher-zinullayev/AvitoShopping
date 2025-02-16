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
        // Create your use case dependencies (this might come from a factory in your real app)
        let fetchUseCase: FetchProductDetailUseCaseProtocol = FetchProductDetailUseCase(repository: ProductRepository(networkService: NetworkService()))
        let addToCartUseCase: AddToCartUseCaseProtocol = AddToCartUseCase(repository: ShoppingCartRepositoryImpl())
        let checkInCartUseCase: CheckProductInCartUseCaseProtocol = CheckProductInCartUseCase(repository: ShoppingCartRepositoryImpl())
        
        // Create the view model with the product id (converted to String if needed)
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
