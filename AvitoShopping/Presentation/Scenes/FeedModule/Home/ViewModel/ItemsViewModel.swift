//
//  ItemsViewModel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

final class ItemsViewModel {
    private(set) var state: ItemsViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ItemsViewState) -> Void)?
    
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let addFavoriteUseCase: AddFavoriteProductUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let coordinator: ItemsCoordinatorProtocol
    
    private var pagination = Pagination()
    var currentFilter: ProductFilter?
    
    init(coordinator: ItemsCoordinatorProtocol,
         fetchProductsUseCase: FetchProductsUseCaseProtocol,
         addFavoriteUseCase: AddFavoriteProductUseCaseProtocol,
         addToCartUseCase: AddToCartUseCaseProtocol) {
        self.coordinator = coordinator
        self.fetchProductsUseCase = fetchProductsUseCase
        self.addFavoriteUseCase = addFavoriteUseCase
        self.addToCartUseCase = addToCartUseCase
    }
    
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
    
    func applyFilter(_ filter: ProductFilter) {
        currentFilter = filter
        pagination.reset()
        state = .loading
        Task {
            do {
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
    
    func clearFilter() {
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
    
    private func loadProducts() {
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
    
    private func loadMore() {
        Task {
            do {
                let products: [ProductDTO]
                if let filter = currentFilter {
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
    
    private func getItemViewModels(from products: [ProductDTO]) -> [ProductItemViewModel] {
        return products.map { product in
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
