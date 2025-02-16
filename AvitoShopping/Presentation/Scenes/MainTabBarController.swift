//
//  MainTabBarController.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 16.02.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = createViewControllers()
    }
    
    private func createViewControllers() -> [UIViewController] {
        let networkService = NetworkService()
        let productRepository = ProductRepository(networkService: networkService)
        let favoriteProductRepository = FavoriteProductRepositoryImpl()
        let shoppingCartRepository = ShoppingCartRepositoryImpl()
        
        let fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
        let addFavoriteUseCase = AddFavoriteProductUseCase(repository: favoriteProductRepository)
        let addToCartUseCase = AddToCartUseCase(repository: shoppingCartRepository)
        
        let itemsNavigationController = UINavigationController()
        let itemsCoordinator = ItemsCoordinator(navigationController: itemsNavigationController)
        let itemsViewModel = ItemsViewModel(
            coordinator: itemsCoordinator,
            fetchProductsUseCase: fetchProductsUseCase,
            addFavoriteUseCase: addFavoriteUseCase,
            addToCartUseCase: addToCartUseCase
        )
        let itemsVC = ItemsViewController(viewModel: itemsViewModel)
        itemsNavigationController.viewControllers = [itemsVC]
        itemsNavigationController.tabBarItem = UITabBarItem(
            title: "Продукты",
            image: UIImage(systemName: "bag"),
            tag: 0
        )
        
        let cartVC = ShoppingCartViewController()
        let cartNavigationController = UINavigationController(rootViewController: cartVC)
        cartNavigationController.tabBarItem = UITabBarItem(
            title: "Корзина",
            image: UIImage(systemName: "cart.fill"),
            tag: 1
        )
        
        return [itemsNavigationController, cartNavigationController]
    }
}
