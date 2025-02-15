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
        let detailVC = ProductDetailViewController(product: product)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
