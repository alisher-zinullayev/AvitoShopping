//
//  ItemsViewModel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

protocol ItemsCoordinatorProtocol {
    func showProductDetails(_ product: ProductDTO)
}

import UIKit

final class ItemsCoordinator: ItemsCoordinatorProtocol {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showProductDetails(_ product: ProductDTO) {
        // Создаем детальный экран для выбранного товара
        let detailVC = ProductDetailViewController(product: product)
        navigationController.pushViewController(detailVC, animated: true)
    }
}

final class ItemsViewModel: ObservableObject {
    private(set) var state: ItemsViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    // Closure for binding state changes to the UI
    var onStateChange: ((ItemsViewState) -> Void)?
    
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let addFavoriteUseCase: AddFavoriteProductUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let coordinator: ItemsCoordinatorProtocol
    
    private var pagination = Pagination()
     var currentFilter: ProductFilter?  // Stores the active filter, if any.
    
    init(coordinator: ItemsCoordinatorProtocol,
         fetchProductsUseCase: FetchProductsUseCaseProtocol,
         addFavoriteUseCase: AddFavoriteProductUseCaseProtocol,
         addToCartUseCase: AddToCartUseCaseProtocol) {
        self.coordinator = coordinator
        self.fetchProductsUseCase = fetchProductsUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.addToCartUseCase = addToCartUseCase
    }
    
    // Handle events from the view (e.g. onAppear, willDisplayLastItem)
    func handle(_ event: ItemsViewEvent) {
        switch event {
        case .onAppear:
            loadProducts()
        case .willDisplayLastItem:
            loadMore()
        case .onSelectItem(let product):
            coordinator.showProductDetails(product)
        }
    }
    
    // Called when the user applies a filter
    func applyFilter(_ filter: ProductFilter) {
        currentFilter = filter
        pagination.reset()
        state = .loading
        
        Task {
            do {
                // For debugging: you might want to print the generated URL.
                // let config = ProductNetworkConfig.filteredProducts(title: filter.title,
                //                                                    priceMin: filter.priceMin,
                //                                                    priceMax: filter.priceMax,
                //                                                    categoryId: filter.categoryId,
                //                                                    offset: filter.offset,
                //                                                    limit: filter.limit)
                // let fullURL = "https://api.escuelajs.co/api/v1/" + config.path + config.endPoint
                // print("Filtered URL: \(fullURL)")
                
                let products = try await fetchProductsUseCase.executeFiltered(filter: filter)
                if products.isEmpty {
                    state = .loaded(ViewData(products: []))
                    return
                }
                if products.count < pagination.limit {
                    pagination.totalCount = pagination.offset + products.count
                }
                pagination.nextPage()
                let viewModels = getItemViewModels(from: products)
                state = .loaded(ViewData(products: viewModels))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}

extension ItemsViewModel {
    func clearFilter() {
        // Clear any active filter.
        currentFilter = nil
        pagination.reset()
        state = .loading
        Task {
            do {
                let products = try await fetchProductsUseCase.execute(offset: pagination.offset,
                                                                      limit: pagination.limit)
                if products.count < pagination.limit {
                    pagination.totalCount = pagination.offset + products.count
                }
                pagination.nextPage()
                let viewModels = getItemViewModels(from: products)
                state = .loaded(ViewData(products: viewModels))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}

private extension ItemsViewModel {
    func loadProducts() {
        // If a filter is active, load filtered products instead.
        if let filter = currentFilter {
            applyFilter(filter)
            return
        }
        
        if case .idle = state {
            state = .loading
            pagination.reset()
        }
        
        Task {
            do {
                let products = try await fetchProductsUseCase.execute(offset: pagination.offset,
                                                                      limit: pagination.limit)
                if products.isEmpty {
                    state = .loaded(ViewData(products: []))
                    return
                }
                if products.count < pagination.limit {
                    pagination.totalCount = pagination.offset + products.count
                }
                pagination.nextPage()
                let viewModels = getItemViewModels(from: products)
                state = .loaded(ViewData(products: viewModels))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func loadMore() {
        Task {
            do {
                let products: [ProductDTO]
                if let filter = currentFilter {
                    // Create a new filter with the current pagination values
                    let updatedFilter = ProductFilter(
                        title: filter.title,
                        priceMin: filter.priceMin,
                        priceMax: filter.priceMax,
                        categoryId: filter.categoryId,
                        offset: pagination.offset,
                        limit: pagination.limit
                    )
                    products = try await fetchProductsUseCase.executeFiltered(filter: updatedFilter)
                } else {
                    products = try await fetchProductsUseCase.execute(offset: pagination.offset,
                                                                      limit: pagination.limit)
                }
                // If no products were returned, don't update the state further.
                if products.isEmpty { return }
                if products.count < pagination.limit {
                    pagination.totalCount = pagination.offset + products.count
                }
                pagination.nextPage()
                let newViewModels = getItemViewModels(from: products)
                if case .loaded(let existingData) = state {
                    let allProducts = existingData.products + newViewModels
                    state = .loaded(ViewData(products: allProducts))
                } else {
                    state = .loaded(ViewData(products: newViewModels))
                }
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func getItemViewModels(from products: [ProductDTO]) -> [ProductItemViewModel] {
        return products.map { product in
            // Clean the URL if necessary
            let rawURL = product.images.first ?? ""
            let cleanURL = rawURL.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))
            return ProductItemViewModel(
                id: product.id,
                title: product.title,
                description: product.description,
                price: product.price,
                imageUrl: cleanURL,
                originalDTO: product
            )
        }
    }
}
