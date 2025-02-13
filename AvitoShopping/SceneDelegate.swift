//
//  SceneDelegate.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    //    internal var window: UIWindow?
    //    //    private var appCoordinator: AppCoordinator?
    //
    //    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    //        guard let windowScene = (scene as? UIWindowScene) else { return }
    //
    //        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    //        window?.windowScene = windowScene
    //
    //        //        let navigationController = UINavigationController()
    //        //        appCoordinator = AppCoordinator(navigationController: navigationController)
    //        //        appCoordinator?.start()
    //
    //        //        window?.rootViewController = navigationController
    //        let networkService = NetworkService()
    //        // 2. Репозиторий, использующий NetworkService и пагинацию
    //        let productRepository = ProductRepository(networkService: networkService)
    //        // 3. Use Case для получения списка товаров
    //        let fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
    //        // 4. ViewModel для экрана списка товаров (Items)
    //        let itemsViewModel = ItemsViewModel(coordinator: <#any ItemsCoordinatorProtocol#>, fetchProductsUseCase: fetchProductsUseCase)
    //        // 5. Создаем ItemsViewController (UIKit), внедряя в него ViewModel
    //        let itemsViewController = ItemsViewController(viewModel: itemsViewModel)
    //        window?.rootViewController = itemsViewController
    //        window?.makeKeyAndVisible()
    //    }
    
    internal var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create network layer dependencies
        let networkService = NetworkService()
        let productRepository = ProductRepository(networkService: networkService)
        let favoriteProductRepository = FavoriteProductRepositoryImpl()
        let shoppingCartRepository = ShoppingCartRepositoryImpl()
        let fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)
        let addFavoriteUseCase = AddFavoriteProductUseCase(repository: favoriteProductRepository)
        let addToCartUseCase = AddToCartUseCase(repository: shoppingCartRepository)
        // Initialize the view model without a coordinator
        let viewModel = ItemsViewModel(fetchProductsUseCase: fetchProductsUseCase,
                                       addFavoriteUseCase: addFavoriteUseCase,
                                       addToCartUseCase: addToCartUseCase)
        
        // Create the ItemsViewController with the view model
        let itemsViewController = ItemsViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: itemsViewController)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

