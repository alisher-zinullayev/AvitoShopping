//
//  ItemsViewModel.swift
//  AvitoShopping
//
//  Created by Alisher Zinullayev on 11.02.2025.
//

import Foundation

final class ItemsViewModel: ObservableObject {
    private(set) var state: ItemsViewState = .idle {
        didSet {
            onStateChange?(state)
        }
    }
    
    var onStateChange: ((ItemsViewState) -> Void)?
    
//    private let coordinator: ItemsCoordinatorProtocol
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let addFavoriteUseCase: AddFavoriteProductUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    
    private var pagination = Pagination()
    
    init(fetchProductsUseCase: FetchProductsUseCaseProtocol,
         addFavoriteUseCase: AddFavoriteProductUseCaseProtocol,
         addToCartUseCase: AddToCartUseCaseProtocol) {
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
//        case .onSelectItem(let id):
//            coordinator.showProductDetails(id: id)
        }
    }
    
    func favoriteButtonTapped(for product: ProductDTO) {
        do {
            try addFavoriteUseCase.execute(product: product)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func addToCartButtonTapped(for product: ProductDTO) {
        do {
            try addToCartUseCase.execute(product: product)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

private extension ItemsViewModel {
    func loadProducts() {
        if case .idle = state {
            state = .loading
            pagination.reset()
        }
        
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
    
    func loadMore() {
        Task {
            do {
                let products = try await fetchProductsUseCase.execute(offset: pagination.offset,
                                                                      limit: pagination.limit)
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
    
    func cleanURLString(_ urlString: String) -> String {
        return urlString.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))
    }
    
    func getItemViewModels(from products: [ProductDTO]) -> [ProductItemViewModel] {
        return products.map { product in
            
                let rawURL = product.images.first ?? ""
                let cleanURL = cleanURLString(rawURL)
            print(cleanURL)
            return ProductItemViewModel(
                id: product.id,
                title: product.title,
                description: product.description,
                price: product.price,
                imageUrl: cleanURL//product.images.first ?? "" //product.category.image
            )
        }
    }
}
